//+------------------------------------------------------------------+
//|                                                         3EMA.mq4 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Puchite Sangiamking"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#include "IndicatorEMA.mq4"
indicatorEMA indidate = new indicatorEMA();
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
extern double lotSize = 0.01;
extern int maxOrder = 4;
extern int tailStop = 250;
bool checkMagin = false;
double maginBuy,
       maginSell;
datetime time;
bool started = false;
int OnInit()
  {
//---
   started = false;
   indidate.getlot(lotSize);
   indidate.getMax(maxOrder);
   indidate.getTailstop(tailStop);
   indidate.prevHigh = 0;
   indidate.prevLow = 9999;
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   if(indidate.zigzag>0)
   {
      started = true;
   }
      
   maginBuy = AccountFreeMarginCheck(Symbol(),OP_BUY,lotSize);
   maginSell = AccountFreeMarginCheck(Symbol(),OP_SELL,lotSize);
   
   if(maginBuy>0 && maginSell>0)
   {
      checkMagin = true;
   }
   
   if(OrdersTotal()<maxOrder && checkMagin==true)
   {
      indidate.calculate();
   }
   
   if(OrdersTotal()>0)
      {
         
         //indidate.orderClose();  
         if(time<TimeCurrent())
         {
            indidate.tailStop();
            time = TimeCurrent()+1*60;  
         }                      
      }
   indidate.indicate();
   Comment("\nlotSize :",indidate.lotSize,
           "\nMaxOrder:",indidate.maxOrder,
           "\nAvailable Magin :",checkMagin,
           "\nTailingStop:",indidate.tailingStop,
           "\nStarted:",started,
           "\nZigZag:",indidate.zigzag
           );
           
         
 }

//+------------------------------------------------------------------+
