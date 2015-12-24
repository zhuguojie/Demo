//
//  MainViewController.m
//  youzanIOSDemo
//
//  Copyright (c) 2012-2015 © youzan.com. All rights reserved.
//

#import "MainViewController.h"
#import "JsBridgeModel.h"
#import "LoginDataModel.h"

@interface MainViewController ()<UIWebViewDelegate>

@property (strong , nonatomic) IBOutlet UIWebView *webView;
@property (strong,nonatomic) UIView *backView;//返回的名称
@property (strong, nonatomic) UIBarButtonItem  *rightBarButtonItem;
@property (strong, nonatomic) UIButton *sysButton;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //默认打开的登陆方式
    
    [self initBackButton];
    
    _webView.delegate = self;
    UIBarButtonItem *leftBar = [[UIBarButtonItem alloc] initWithCustomView:_backView];
    leftBar.style = UIBarButtonItemStylePlain;
    self.navigationItem.leftBarButtonItem = leftBar;
    self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
    
    _sysButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [_sysButton setTitle:@"分享" forState:UIControlStateNormal];
    [_sysButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_sysButton addTarget:self action:@selector(sharePage) forControlEvents:UIControlEventTouchUpInside];
    _sysButton.tag = 10001;
    
    _rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_sysButton];
    NSDictionary* textAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:16]};
    _rightBarButtonItem.enabled = NO;
    [[UIBarButtonItem appearance] setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
    
    _sysButton.hidden = YES;
    
    self.navigationItem.rightBarButtonItem = _rightBarButtonItem;
    
    [self loadRequestFromString:@"http://detail.koudaitong.com/show/goods?alias=bm74n1ih&v2/goods/bm74n1ih"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadRequestFromString:(NSString*)urlString {
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:urlRequest];
}

- (void)initBackButton {
    
    _backView = [[UIView alloc] initWithFrame:CGRectMake(0,0, 40, 44)];
    [self.view addSubview:_backView];
    
    UIButton *sysButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 44)];
    [sysButton setTitle:@"返回" forState:UIControlStateNormal];
    [sysButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sysButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    sysButton.tag = 10001;

    [_backView addSubview:sysButton];
    
}

- (void) backButtonPressed:(UIButton *) sender {
    
    if ([_webView canGoBack]) {
        [_webView goBack];
    }
}

#pragma mark - Webview Delegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    self.navigationItem.title = @"载入中...";
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.navigationItem.title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    [self.webView stringByEvaluatingJavaScriptFromString:[[JsBridgeModel sharedManage] JsBridgeWhenWebDidLoad]];//js文件初始化
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSURL *url = [request URL];
    NSLog(@"url string: %@" , [url absoluteString]);
    
    if(![[url absoluteString] hasPrefix:@"http"]){//非http
        
        NSString *jsBridageString = [[JsBridgeModel sharedManage] parseYOUZANScheme:url];
        
        if(jsBridageString) {
            
            if([jsBridageString isEqualToString:@"check_login"]) {//检测登陆 同步用户信息
                //直接同步信息
                NSDictionary *userInfo  = @{@"gender":@"1",
                                            @"user_id":@"13600001111",
                                            @"user_name":@"xiaokai",
                                            @"telephone":@"13532323412",
                                            @"nick_name":@"xiaokai",
                                            @"avatar":@"1"};
                NSString *string = [[JsBridgeModel sharedManage]  webUserInfoLogin:userInfo];
                [self.webView stringByEvaluatingJavaScriptFromString:string];
                return YES;
                
            } else if([jsBridageString isEqualToString:@"share_data"]) {//分享请求捕获
                
                NSDictionary * shareDic = [[JsBridgeModel sharedManage] ShareDataInfo:url];
                
                if(shareDic[@"desc"]) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享信息获取成功" message:@"" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    [alertView show];
                }
                NSLog(@"输出分享信息： %@ " , shareDic);
               
            } else if([jsBridageString isEqualToString:@"web_ready"]) { //页面资源加载完毕
                self.navigationItem.rightBarButtonItem.enabled = YES;
                _sysButton.hidden = NO;
            }
        }
        
        
        
        
        
        
//       你好你好你好你好你好
    }
    return YES;
}


//登陆：采用有赞的Oauth2.0的登陆方式
- (IBAction)loginButtonClick:(id)sender {
    
    NSDictionary *userInfo  = @{@"gender":@"1",
                                @"user_id":@"13600001111",
                                @"user_name":@"xiaokai",
                                @"telephone":@"13532323412",
                                @"nick_name":@"xiaokai",
                                @"avatar":@""};
    NSString *string = [[JsBridgeModel sharedManage]  webUserInfoLogin:userInfo];
    [self.webView stringByEvaluatingJavaScriptFromString:string];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"客户端数据同步到web" message:@"" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alertView show];
}

- (void)sharePage { //启动web分享回调
    [self.webView stringByEvaluatingJavaScriptFromString:[[JsBridgeModel sharedManage] JsBridgeWhenShareBtnClick]];
}
@end
