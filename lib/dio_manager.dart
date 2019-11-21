import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'global_config.dart';
import 'result_code.dart';

/*
 * 网络请求管理类
 */
class DioManager {
  
  static DioManager _instance;
  Dio dio;
  BaseOptions options;

  // 写一个单例
  // 在 Dart 里，带下划线开头的变量是私有变量
  static DioManager getInstance() {
    if (_instance == null) {
      _instance = DioManager();
    }
    return _instance;
  }

  // 构造函数
  DioManager() {
    // BaseOptions、Options、RequestOptions 都可以配置参数，
    // 优先级别依次递增，且可以根据优先级别覆盖参数
    options = new BaseOptions(
      //请求基地址,可以包含子路径
      baseUrl: "https://cnodejs.org/api/v1",
      //连接服务器超时时间，单位是毫秒.
      connectTimeout: 10000,
      //响应流上前后两次接受到数据的间隔，单位为毫秒。
      receiveTimeout: 5000,
      //Http请求头.
      headers: {
        "version": '2.0.9',
        "Authorization": '_token',
      },
      //请求的Content-Type，默认值是[ContentType.json].
      //也可以用ContentType.parse("application/x-www-form-urlencoded")
      // contentType: '"application/json"',
      //表示期望以那种格式(方式)接受响应数据。
      //接受4种类型 `json`, `stream`, `plain`, `bytes`. 默认值是 `json`,
      responseType: ResponseType.json,
    );
    dio = new Dio(options);

    //  是否开启请求日志
    dio.interceptors.add(LogInterceptor(responseBody: GlobalConfig.isDebug)); 
    //  缓存相关类，具体设置见https://github.com/flutterchina/cookie_jar
    dio.interceptors.add(CookieManager(CookieJar())); 

    //  添加拦截器
    dio.interceptors
        .add(InterceptorsWrapper(onRequest: (RequestOptions options) {
      print("请求之前");
      // Do something before request is sent
      return options; //continue
    }, onResponse: (Response response) {
      print("响应之前");
      // Do something with response data
      return response; // continue
    }, onError: (DioError e) {
      print("错误之前");
      // Do something with response error
      return e; //continue
    }));
  }

  //get请求
  get(String url, params, Function successCallBack,
      Function errorCallBack,{cancelToken}) async {
    _requstHttp(url, successCallBack, 'get', params, errorCallBack,cancelToken);
  }

  //post请求
  post(String url, params, Function successCallBack,
      Function errorCallBack ,{cancelToken}) async {
    _requstHttp(url, successCallBack, "post", params, errorCallBack,cancelToken);
  }

  /**
   * cancelToken 取消请求
   */
  _requstHttp(String url, Function successCallBack,
      [String method, params, Function errorCallBack,CancelToken cancelToken]) async {
    Response response;
    try {
      if (method == 'get') {
        if (params.length > 0) {
          response = await dio.get(url, queryParameters: params,cancelToken: cancelToken);
        } else {
          response = await dio.get(url);
        }
      } else if (method == 'post') {
        if (params.length > 0) {
          response = await dio.post(url, data: params);
        } else {
          response = await dio.post(url);
        }
      }
    } on DioError catch (error) {
      // 请求错误处理
      Response errorResponse;
      if (error.response != null) {
        errorResponse = error.response;
      } else {
        errorResponse = new Response(statusCode: 666);
      }
      // 请求超时
      if (error.type == DioErrorType.CONNECT_TIMEOUT) {
        errorResponse.statusCode = ResultCode.CONNECT_TIMEOUT;
      }
      // 一般服务器错误
      else if (error.type == DioErrorType.RECEIVE_TIMEOUT) {
        errorResponse.statusCode = ResultCode.RECEIVE_TIMEOUT;
      }

      // debug模式才打印
      if (GlobalConfig.isDebug) {
        print('请求异常: ' + error.toString());
        print('请求异常url: ' + url);
        print('请求头: ' + dio.options.headers.toString());
        print('method: ' + dio.options.method);
      }
      _error(errorCallBack, error.message);
      return '';
    }
    // debug模式打印相关数据
    if (GlobalConfig.isDebug) {
      print('请求url: ' + url);
      print('请求头: ' + dio.options.headers.toString());
      if (params != null) {
        print('请求参数: ' + params.toString());
      }
      if (response != null) {
        print('返回参数: ' + response.toString());
      }
    }
    String dataStr = json.encode(response.data);
    Map<String, dynamic> dataMap = json.decode(dataStr);
    if (dataMap == null || dataMap['state'] == 0) {
      _error(
          errorCallBack,
          '错误码：' +
              dataMap['errorCode'].toString() +
              '，' +
              response.data.toString());
    } else if (successCallBack != null) {
      successCallBack(dataMap);
    }
  }

  _error(Function errorCallBack, String error) {
    if (errorCallBack != null) {
      errorCallBack(error);
    }
  }

    /*
   * 下载文件
   */
  downloadFile(urlPath, savePath) async {
    Response response;
    try {
      response = await dio.download(urlPath, savePath,onReceiveProgress: (int count, int total){
        //进度
        print("$count $total");
      });
      print('downloadFile success---------${response.data}');
    } on DioError catch (e) {
      print('downloadFile error---------$e');
      formatError(e);
    }
    return response.data;
  }

  /*
   * error统一处理
   */
  void formatError(DioError e) {
    if (e.type == DioErrorType.CONNECT_TIMEOUT) {
      // It occurs when url is opened timeout.
      print("连接超时");
    } else if (e.type == DioErrorType.SEND_TIMEOUT) {
      // It occurs when url is sent timeout.
      print("请求超时");
    } else if (e.type == DioErrorType.RECEIVE_TIMEOUT) {
      //It occurs when receiving timeout
      print("响应超时");
    } else if (e.type == DioErrorType.RESPONSE) {
      // When the server response, but with a incorrect status, such as 404, 503...
      print("出现异常");
    } else if (e.type == DioErrorType.CANCEL) {
      // When the request is cancelled, dio will throw a error with this type.
      print("请求取消");
    } else {
      //DEFAULT Default error type, Some other Error. In this case, you can read the DioError.error if it is not null.
      print("未知错误");
    }
  }

   /*
   * 取消请求
   *
   * 同一个cancel token 可以用于多个请求，当一个cancel token取消时，所有使用该cancel token的请求都会被取消。
   * 所以参数可选
   */
  void cancelRequests(CancelToken token) {
    token.cancel("cancelled");
  }

}
