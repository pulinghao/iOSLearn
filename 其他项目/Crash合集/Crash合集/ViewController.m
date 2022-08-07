//
//  ViewController.m
//  Crash合集
//
//  Created by pulinghao on 2022/8/7.
//

#import "ViewController.h"
#import <mach/mach.h>

#include <execinfo.h>


@interface ViewController ()

@end

@implementation ViewController



void InstallSignalHandler(void) {
    signal(SIGHUP, handleSignalException); // 注册监听
    signal(SIGINT, handleSignalException);
    signal(SIGQUIT, handleSignalException);
    signal(SIGABRT, handleSignalException);
    signal(SIGILL, handleSignalException);
    signal(SIGSEGV, handleSignalException);
    signal(SIGFPE, handleSignalException);
    signal(SIGBUS, handleSignalException);
    signal(SIGPIPE, handleSignalException);
}

void handleSignalException(int signal) {
    NSMutableString * crashInfo = [[NSMutableString alloc]init];
    [crashInfo appendString:[NSString stringWithFormat:@"signal:%d\n",signal]];
    [crashInfo appendString:@"Stack:\n"];
    void* callstack[128];
    int i, frames = backtrace(callstack, 128);
    char** strs = backtrace_symbols(callstack, frames);
    for (i = 0; i <frames; ++i) {
        [crashInfo appendFormat:@"%s\n", strs[i]];
    }
    NSLog(@"%@", crashInfo);
}

// 构造BAD MEM ACCESS Crash
- (void)makeCrash2 {
  NSLog(@"********** Make a [BAD MEM ACCESS] now. **********");
  *((int *)(0x1234)) = 122;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // make Crash
//    [self.class createAndSetExceptionPort];
    
    // make Crash 2
    InstallSignalHandler();
}

+ (void)createAndSetExceptionPort {
    mach_port_t server_port;
    kern_return_t kr = mach_port_allocate(mach_task_self(), MACH_PORT_RIGHT_RECEIVE, &server_port);
    assert(kr == KERN_SUCCESS);
    NSLog(@"create a port: %d", server_port);

    kr = mach_port_insert_right(mach_task_self(), server_port, server_port, MACH_MSG_TYPE_MAKE_SEND);
    assert(kr == KERN_SUCCESS);

    kr = task_set_exception_ports(mach_task_self(), EXC_MASK_BAD_ACCESS | EXC_MASK_CRASH, server_port, EXCEPTION_DEFAULT | MACH_EXCEPTION_CODES, THREAD_STATE_NONE);

    [self setMachPortListener:server_port];
}

+ (void)setMachPortListener:(mach_port_t)mach_port {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      mach_msg_header_t mach_message;

      mach_message.msgh_size = 1024;
      mach_message.msgh_local_port = mach_port;

      mach_msg_return_t mr;

      while (true) {
          mr = mach_msg(&mach_message,
                        MACH_RCV_MSG | MACH_RCV_LARGE,
                        0,
                        mach_message.msgh_size,
                        mach_message.msgh_local_port,
                        MACH_MSG_TIMEOUT_NONE,
                        MACH_PORT_NULL);

          if (mr != MACH_MSG_SUCCESS && mr != MACH_RCV_TOO_LARGE) {
              NSLog(@"error!");
          }

          mach_msg_id_t msg_id = mach_message.msgh_id;
          mach_port_t remote_port = mach_message.msgh_remote_port;
          mach_port_t local_port = mach_message.msgh_local_port;

          NSLog(@"Receive a mach message:[%d], remote_port: %d, local_port: %d",
                msg_id,
                remote_port,
                local_port);
          abort();
      }
  });
}


// 构造BAD MEM ACCESS Crash
- (void)makeCrash {
  NSLog(@"********** Make a [BAD MEM ACCESS] now. **********");
  *((int *)(0x1234)) = 122;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self makeCrash];
}
@end
