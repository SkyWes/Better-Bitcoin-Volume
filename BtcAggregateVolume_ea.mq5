const string url_M1="https://data.bitcoinity.org/export_data.csv?c=e&data_type=volume&r=minute&t=b&timespan=24h";
const string url_H1="https://data.bitcoinity.org/export_data.csv?c=e&data_type=volume&r=hour&t=b&timespan=30d";
const string url_D1 = "https://data.bitcoinity.org/export_data.csv?c=e&data_type=volume&r=day&t=b&timespan=2y"; //73


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

inline void InitArray(int size){  ArrayResize(btc_dt,size);
                                  ArrayResize(btc_vol,size);
                                  ArrayInitialize(btc_vol,0); }
                                  

                                  
int BtcDateTransform(int index, string time) { return time=="hour" ? btc_dt[index].hour : btc_dt[index].min; }
int TotalSubwindows(){ return (int)ChartGetInteger(0,CHART_WINDOWS_TOTAL); }
MqlDateTime btc_dt[];
double      btc_vol[];
int ind{};
datetime time_current[1];
datetime last_time[1];
int IndicatorFound() { return ChartWindowFind(ChartID(),"BtcVolume"); }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   time_current[0]=-1;
   last_time[0]=-1;
   
//   if(IndicatorFound()<0){
//      int i_handle= iCustom(_Symbol,PERIOD_CURRENT,"BtcAggregateVolume.ex5");
//   
//      if(i_handle!=INVALID_HANDLE){
//         ChartIndicatorAdd(ChartID(),TotalSubwindows(),i_handle);  
//      } else {
//         Print("Failed to create BtcVolume indicator. Error code : ",GetLastError());
//      }
//    }

   return(INIT_SUCCEEDED);
  }

void OnTick() {
   if(NewBar() && Period()!=PERIOD_W1 && Period()!=PERIOD_MN1){
      Sleep(1000);
      
      WebData();
      
      if(Period()!=PERIOD_D1 && Period()!=PERIOD_H1 && Period()!=PERIOD_M1) {
         switchTimeframe();
      }else {ind = ArraySize(btc_dt) - 1;}
      PrintFile();
      PrintTest();
      
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   
   //if(!ChartIndicatorDelete(ChartID(),IndicatorFound(),"BtcVolume")){Print("Failed to delete indicator");}
}
void      WebData()
  {
   string cookie=NULL, headers;
   string reqheaders="User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.102 Safari/537.36 Edge/18.19042\r\n";
   char post[],result[];
   string url;
   string test;
   
   SelectURL(url);
   
   int res;
   int i{};
   ResetLastError();
   int timeout=5000;
   
   res=WebRequest("GET",url,reqheaders,timeout,post,result,headers); //This function is sloooooow! 2.7 seconds on avg
   
   if(res==-1)
     {
      Print("Error in WebRequest. Error code  =",GetLastError());
      //--- Perhaps the URL is not listed, display a message about the necessity to add the address
      MessageBox("Add the address '"+url+"' in the list of allowed URLs on tab 'Expert Advisors'","Error",MB_ICONINFORMATION);
     }
   else
     {
      PrintFormat("The file has been successfully downloaded, File size =%d bytes.",ArraySize(result));
      //--- Save the data to a file
      test=CharArrayToString(result,0,-1,CP_ACP);
      int filehandle=FileOpen("Bitcoinity_volume_table.csv",FILE_WRITE|FILE_CSV|FILE_ANSI,",",CP_ACP);
      //--- Checking errors
      if(filehandle!=INVALID_HANDLE)
        {
         //--- Save the contents of the result[] array to a file
         FileWriteString(filehandle,test);

         // --- Close the file
         FileClose(filehandle);
        }
      else
         Print("Error in FileOpen. Error code=",GetLastError());
      
      int h_file=FileOpen("Bitcoinity_volume_table.csv",FILE_READ|FILE_CSV|FILE_ANSI,",",CP_ACP);
      if(h_file!=INVALID_HANDLE)
        {
         datetime bar_time;
         //discard headers
         while(!FileIsLineEnding(h_file))
           {
            FileReadString(h_file);
           }
         while(!FileIsEnding(h_file) && !_StopFlag)
           {
            bar_time = StringToTime(FileReadString(h_file))+(TimeCurrent()-TimeGMT()+900)/1800*1800;
            TimeToStruct(bar_time,btc_dt[i]);
            while(!FileIsLineEnding(h_file))
              {
               btc_vol[i] += FileReadNumber(h_file);
              }
            i++;
           }
         FileClose(h_file);
        }
      else
         Print("Error in FileOpen. Error code=",GetLastError());
     }
}
void SelectURL(string& url) {
   if(Period()>=PERIOD_D1)
     {
      url=url_D1;
      InitArray(730);
     }
   else
      if(Period() >= PERIOD_H1)
        {
         url=url_H1;
         InitArray(719);
        }
      else
        {
         url = url_M1;
         InitArray(1441);
        }
}

void switchTimeframe()
  {

   ENUM_TIMEFRAMES Timeframes = Period();
   string time{""};
   int tf{};
   if(Timeframes>=PERIOD_H1)
     {
      tf = (PeriodSeconds(Timeframes)/60)/60;
      time = "hour";
     }
   else
     {
      tf = PeriodSeconds(Timeframes)/60;
     }

   BarTransform(btc_dt,btc_vol,tf,time);

}

void BarTransform(MqlDateTime& d[], double& v[], int tf, string time)
  {
   int stop_flag = ArraySize(btc_dt);
   int start{};
   
   
      for(int i = ArraySize(btc_dt) - 1; i>=0; --i)
        {
         if(BtcDateTransform(i,time)%tf==0)
           {
            if(i>ArraySize(btc_dt)-tf)
            stop_flag = i;
            break;
           }
        }
      int i{};
      while(BtcDateTransform(i,time)%tf!=0)
        {
         ++i;
        }
      btc_dt[start] = btc_dt[i];
      if(i>0)
        {
         btc_vol[start] = 0;
         btc_vol[start] = btc_vol[i];
        }
      ++i;
      for(; i < stop_flag; ++i)
        {
         if(BtcDateTransform(i,time)%tf==0)
           {
            ++start;
            btc_dt[start] = btc_dt[i];
            btc_vol[start] = 0;
           }
         btc_vol[start] += btc_vol[i];
         
        }
     ArrayResize(btc_vol,start + 1);
     ind = start;
    
    }
 
//+------------------------------------------------------------------+
void PrintTest()
  {
   printf("last bar : %4d-%02d-%02d, %02d:%02d:%02d ",btc_dt[ind].year,btc_dt[ind].mon,
          btc_dt[ind].day,btc_dt[ind].hour, btc_dt[ind].min, btc_dt[ind].sec);
   Print("                ",btc_vol[ind]);
  }
//+------------------------------------------------------------------+
void PrintFile() {
    int file_h = FileOpen("btc_vol_data.bin",FILE_WRITE|FILE_BIN);
    if(file_h!=INVALID_HANDLE){
    FileWriteArray(file_h,btc_vol,0,WHOLE_ARRAY);
    FileClose(file_h);
    GlobalVariableSet("new data",(double)GetTickCount());
    }
}

bool NewBar(void)
  {
   int copy=-1;
   copy=CopyTime(Symbol(),Period(),0,1,time_current);
   if(copy>0 && time_current[0]>last_time[0])
     {
      last_time[0]=time_current[0];
      return(true);
     }
   else
     {return(false);}
  }