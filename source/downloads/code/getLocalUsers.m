
-(NSArray*)getLocalUsers
{
   NSMutableArray *users = [[NSMutableArray alloc] init];

   NSTask *task;
   task = [[NSTask alloc] init];
   [task setLaunchPath: @"/usr/bin/dscl"];

   NSArray *arguments;
   arguments =
      [NSArray arrayWithObjects: @"localhost", @"list", @"/Search/Users", nil];
   [task setArguments: arguments];

   NSPipe *pipe;
   pipe = [NSPipe pipe];
   [task setStandardOutput: pipe];

   NSFileHandle *file;
   file = [pipe fileHandleForReading];

   [task launch];

   NSData *data;
   data = [file readDataToEndOfFile];

   NSString *string;
   string = [[NSString alloc] initWithData: data encoding:NSUTF8StringEncoding];

   NSScanner *theScanner = [NSScanner scannerWithString:string];

   while (NO == [theScanner isAtEnd])
   {
      NSString *str;
      struct passwd *userInfo;
    
      if ([theScanner scanUpToCharactersFromSet:
            [NSCharacterSet whitespaceAndNewlineCharacterSet]
            intoString:&str])
      {
         userInfo = getpwnam([str UTF8String]);
         if (userInfo->pw_uid > 500)
         {
            [users addObject: str];
         }
      }
   }

   [string release];
   [task release];

   return [users autorelease];
}
