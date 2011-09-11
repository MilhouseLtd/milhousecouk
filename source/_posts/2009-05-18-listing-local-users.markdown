---
layout: post
title: Listing Local Users
tags: [development, os x]
---

Using Directory Services, it is quite easy to get a list of all the user accounts on your OS X computer. From the command line run:

> $ dscl localhost list /Search/Users

Unfortunately, this also lists all the system accounts such as those used by the www and mysql daemons. So if we only want users then we have to do a bit of work to filter out these accounts. Now, when creating users on OS X (and most Unix based systems that I am aware of) they are assigned a User ID starting from 500. So we can simply ignore any accounts with a UID less than 500.

To be able to do this from Objective C within my Cocoa application I had to execute the dscl command from within an NSTask. The code listing below shows how I done this.

The first half of the function sets up the NSTask with the path to the dscl application and the arguments to be passed. The task is then run and the output piped to a file. This is then read into an NSString which we can now process to remove all system accounts. Using an NSScanner we iterate through the string calling the standard C library function getpwnam() to discover the UID of each account. If it is less than 500 then the user name is added to the array initialised at the start of the function.

Finally return the list of users as an NSArray.

I was doing it this way for a while and it is fine for local users. Problems arise when you need to list network users or need more flexibility so I have recently switched to using the CSIdentity framework.

*Edited to add release for ‘task’ and ‘string’. Thanks go to Jason for spotting that.*

{% highlight objc %}
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
{% endhighlight %}
