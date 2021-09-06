//
//  main.cpp
//  CallBack
//
//  Created by pulinghao on 2021/9/3.
//

#include <iostream>
using namespace std;

// =========== 普通的方式======
typedef void(*DownLoadCallBack)(const char* pURL, bool Ok);


void DownLoadFile(const char* purl, DownLoadCallBack callBack){
    cout <<"downloading"<<purl<<endl;
    callBack(purl,true);
}

void cb(const char* purl,bool ok){
    cout<<"is download"<<endl;
}


// ========== 面向对象 ======
//  很像iOS代理的方法
class IDownloadSink{
public:
    virtual void OnDownLoad(const char* pURL, bool OK) = 0;
};

class CMyDownLoader{
public:
    CMyDownLoader(IDownloadSink* pSink):m_pSink(pSink){
        
    }
    void DownloadFile(const char* pURL){
        cout <<"downloading"<<endl;
        if(m_pSink!= NULL){
            m_pSink->OnDownLoad(pURL, true);
        }
    }
private:
    IDownloadSink *m_pSink;
};

class CMyFile : public IDownloadSink
{
public:
    void download(){
        CMyDownLoader download(this);
        download.DownloadFile("www.baidu.com");
    }
    
    virtual void OnDownLoad(const char* pURL,bool OK){
        cout<<"download finish";
    }
};
int main(int argc, const char * argv[]) {
    // insert code here...
    std::cout << "Hello, World!\n";
    DownLoadFile("www.baidu.com", cb);
    
    CMyFile myFile;
    myFile.download();
    return 0;
}
