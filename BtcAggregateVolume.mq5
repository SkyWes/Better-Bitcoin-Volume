////---Libraries to fix OnDeInit and OnInit synchronization
//#include <TypeToBytes.mqh> // https://www.mql5.com/en/code/16280
//#include <crc64.mqh>       //https://www.mql5.com/en/blogs/post/683577
//#include <Init_Sync.mqh>   //https://www.mql5.com/en/code/18138
//+------------------------------------------------------------------+
//|       BtcAggregateVolume.mq5     by    Skylarwalker              |
//+------------------------------------------------------------------+

#property indicator_separate_window
#property indicator_minimum 0
#property indicator_buffers 1
#property indicator_plots   1
//--- plot btcvl
#property indicator_label1  "btcvl"
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_style1  STYLE_SOLID
#property indicator_width1  3

string   Filename="btc_vol_data.bin";
//--- indicator buffers
double         btcvl[];
double         btcvlBuffer[];
double         old_data;

bool           new_tf;
bool           new_bar;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   old_data = GlobalVariableGet("new data");
   
   IndicatorSetString(INDICATOR_SHORTNAME,"BtcVolume");
   ArraySetAsSeries(btcvl,true);
   ArraySetAsSeries(btcvlBuffer,true);

   PlotIndexSetInteger(0,PLOT_LINE_COLOR,clrRoyalBlue);
//--- indicator buffers mapping
   SetIndexBuffer(0,btcvl,INDICATOR_DATA);
//---
  
   new_tf = true;
    
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double& price[])
  {
   
   if(prev_calculated < rates_total) {
      new_bar = true;
   }
   
   if(new_tf) {
      ArrayInitialize(btcvl,0);
   }
   
   if(GlobalVariableGet("new data")!=old_data && !IsStopped()){
      if(new_bar && new_tf == false){
            ReadFile(Filename);
            btcvl[0] = 0;
            btcvl[1] = btcvlBuffer[0];
            old_data=GlobalVariableGet("new data");
            new_bar = false;
         }
       if(new_tf){
         
         ArrayRemove(btcvlBuffer,0,WHOLE_ARRAY);
         ReadFile(Filename);
         ArrayCopy(btcvl,btcvlBuffer,1,0,ArraySize(btcvlBuffer));
         old_data=GlobalVariableGet("new data");
         new_tf = false;
       }
      
     }
   
   
   return(rates_total);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ReadFile(string file)
  {
   if(file==Filename)
     {
      int v_file=FileOpen(Filename,FILE_READ|FILE_BIN);
      if(v_file!=INVALID_HANDLE)
        {
         FileReadArray(v_file,btcvlBuffer,0,WHOLE_ARRAY);
         FileClose(v_file);
        }
     }

  }
  
