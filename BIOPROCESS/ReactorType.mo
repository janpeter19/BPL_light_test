within BIOPROCESS;
model ReactorType
  extends SimpleBioProcess; 
  
  LiquidCon port;
  
equation

  port.S = S;
  port.X = X;
  port.P = P;

end ReactorType;
