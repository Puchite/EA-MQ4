class indicatorEMA
{
   public:    
      double currentGraph;
      double currentTrend;
      double ema5;
      double ema25;
      double ema50;
      double lotSize;
      int maxOrder;
      int high;
      double highest;
      int low;
      double lowest;
      int tailingStop;
      double zigzag;
      double prevZigZag;
      double sar;
      double prevHigh;
      double prevLow;
      
      void getlot(double lotsize)
      {
         lotSize = lotsize;
      }
      void getMax(int maxorder)
      {
         maxOrder = maxorder;
      }
      void getTailstop(int tailStop)
      {
         tailingStop = tailStop;
      }
      
      void indicate()
      {  
         //currentGraph = iMA(Symbol(),PERIOD_M5,1,0,MODE_EMA,PRICE_WEIGHTED,0);
         //currentTrend = iMA(Symbol(),PERIOD_M5,200,0,MODE_EMA,PRICE_WEIGHTED,0);
         ema5 = iMA(Symbol(),PERIOD_M5,5,0,MODE_EMA,PRICE_CLOSE,0);
         ema25 = iMA(Symbol(),PERIOD_M5,25,0,MODE_EMA,PRICE_CLOSE,0);
         ema50 = iMA(Symbol(),PERIOD_M5,50,0,MODE_EMA,PRICE_CLOSE,0);
         high = iHighest(NULL,0,MODE_HIGH,42,0);
         low = iLowest(NULL,0,MODE_LOW,42,0); 
         highest = High[high];
         lowest = Low[low];
         zigzag = iCustom(Symbol(),PERIOD_M5,"ZigZag",12,5,3,0,0);
         //bollLow = iBands(NULL,0,20,2,0,PRICE_LOW,MODE_LOWER,0);
         //bollUp = iBands(NULL,0,20,2,0,PRICE_LOW,MODE_UPPER,0);
      }
      
      string checkTrend()
      {
         indicate();
         if(currentGraph>currentTrend)
         {
            return "buy";
         }
         else if(currentGraph<currentTrend)
         {
            return "sell";
         }
         return "N";
      }
      
      void counterHigh()
      {
         for(int i=0;i<maxOrder;i++)
         {  
            RefreshRates();
            OrderSend(Symbol(),OP_SELL,lotSize,Bid,5,Bid+(400*Point),Bid-(700*Point),"CounterHigh",0,0,clrRed);   
         }
         return;
      }
      
      void counterLow()
      {
         for(int i=0;i<maxOrder;i++)
         {
            RefreshRates();
            OrderSend(Symbol(),OP_BUY,lotSize,Ask,5,Ask-(400*Point),Ask+(700*Point),"CounterLow",0,0,clrGreen);   
         }
         return;
      }
      void calculate()
      {
         indicate();         
         if(ema5<ema25 && ema5<ema50)
         {  
         
            if(zigzag==lowest)
            {
               counterLow();
            }
                        
            if(ema50>ema25 && ema25-ema5>1.65 && ema50-ema25<1)
            {
               for(int i=0;i<maxOrder-2;i++)
               {
                  RefreshRates();
                  OrderSend(Symbol(),OP_SELL,lotSize,Bid,5,Bid+(200*Point),Bid-(200*Point),"SELL",0,0,clrRed);   
               }
            }
             
            return;        
         }
         else if(ema5>ema25 && ema5>ema50)
         {
            
            if(zigzag==highest)
            {
               counterHigh();
            }
                      
            if(ema25>ema50 && ema5-ema25>1.45 && ema25-ema50<1)
            {          
               for(int j=0;j<maxOrder-2;j++)
               {
                  RefreshRates();
                  OrderSend(Symbol(),OP_BUY,lotSize,Ask,5,Ask-(200*Point),Ask+(200*Point),"BUY",0,0,clrGreen);
               }                    
            }
               
         } 
         return;
        
      }
      
      
      
      void orderClose()
      {
         indicate();         
         for(int count=0;count<OrdersTotal(); count++)
         {
            OrderSelect(count,SELECT_BY_POS,MODE_TRADES);
            if(OrderType()==OP_BUY)
            {
               if(ema5<ema25)
               {
                  for(int b=0;b<3;b++)
                  {
                     RefreshRates();                                        
                     if(OrderClose(OrderTicket(),OrderLots(),Bid,5,clrGreen))
                     {
                        break;
                     }
                  }
               }               
            }
         
            else
            { 
               if(ema5>ema25)
               {
                  for(int s=0;s<3;s++)
                  {
                     RefreshRates();                   
                     if(OrderClose(OrderTicket(),OrderLots(),Ask,5,clrRed))
                     {
                        break;
                     }
                  }
               }               
            }
         }         
      } 
      void tailStop()
      {
         for(int i=0;i<OrdersTotal();i++)
         {
            OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
            if(OrderType()==OP_BUY)
            {
               if(Bid-OrderOpenPrice()>tailingStop*Point)
               {
                  if(OrderStopLoss()<Bid-(tailingStop*Point))
                  {                     
                     OrderModify(OrderTicket(),OrderOpenPrice(),Bid-(tailingStop*Point),OrderTakeProfit(),0,clrNONE);
                     return;            
                  }
               }
            }
            
            else
            {
               if(OrderOpenPrice()-Ask>tailingStop*Point)
               {
                  if(OrderOpenPrice()>Ask+(tailingStop*Point))
                  {
                     OrderModify(OrderTicket(),OrderOpenPrice(),Ask+(tailingStop*Point),OrderTakeProfit(),0,clrNONE);           
                     return;
                  }
               }
            }   
         }
      }   
       
};
