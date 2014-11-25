//
//  w.h
//  LTMobileSDK
//
//  Created by Sergey on 17/11/14.
//  Copyright (c) 2014 LiveTex. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef int LTSVoteType;
typedef int LTSCapabilityType;
typedef NSString * LTSEmployeeId;
typedef NSString * LTSUrl;
typedef NSString * LTSToken;
typedef NSString * LTSStatus;
typedef NSString * LTSTimestamp;
typedef NSString * LTSDepartmentId;
typedef NSString * LTSTextMessageId;
typedef NSMutableDictionary * LTSOptions;

@class LTSEmployee, LTSDepartment;

/////////////////////////LTSCapabilities

@interface LTSCapabilities : NSObject 
+ (LTSCapabilityType)CHAT;
+ (LTSCapabilityType)FILES_RECEIVE;
@end

@interface LTSVoteTypes : NSObject
+ (LTSVoteType)GOOD;
+ (LTSVoteType)BAD;
@end


@interface LTSConversation : NSObject
@property (nonatomic, retain) LTSEmployee *employee;
@property (nonatomic, retain) LTSDepartment *department;

- (id)initWithDepartment:(LTSDepartment *) department
                  employee:(LTSEmployee *) employee;

- (BOOL)departmentIsSet;
- (BOOL)employeeIsSet;
@end



/////////////////////////LTSEmployee

@interface LTSEmployee : NSObject
@property (nonatomic, retain) LTSEmployeeId employeeId;
@property (nonatomic, retain) LTSStatus status;
@property (nonatomic, retain) NSString *firstname;
@property (nonatomic, retain) NSString *lastname;
@property (nonatomic, retain) LTSUrl avatar;
@property (nonatomic, retain) NSString *phone;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) LTSOptions options;

- (id)initWithEmployeeId: (LTSEmployeeId) employeeId
                   status: (LTSStatus) status
                firstname: (NSString *) firstname
                 lastname: (NSString *) lastname
                   avatar: (LTSUrl) avatar
                    phone: (NSString *) phone
                    email: (NSString *) email
                  options: (LTSOptions) options;

- (BOOL)employeeIdIsSet;
- (BOOL)statusIsSet;
- (BOOL)firstnameIsSet;
- (BOOL)lastnameIsSet;
- (BOOL)avatarIsSet;
- (BOOL)phoneIsSet;
- (BOOL)emailIsSet;
- (BOOL)optionsIsSet;
@end



/////////////////////////LTSDepartment

@interface LTSDepartment : NSObject
@property (nonatomic, retain) NSString *departmentId;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) LTSOptions options;

- (id)initWithId:(NSString *) departmentId
            name:(NSString *) name
         options:(LTSOptions) options;

- (BOOL)departmentIdIsSet;
- (BOOL)nameIsSet;
- (BOOL)optionsIsSet;

@end



/////////////////////////LTSDialogState

@interface LTSDialogState : NSObject

@property (nonatomic, retain) LTSConversation *conversation;
@property (nonatomic, retain) LTSEmployee *employee;

- (id)initWithConversation:(LTSConversation *) conversation
                  employee:(LTSEmployee *) employee;

- (BOOL)conversationIsSet;
- (BOOL)employeeIsSet;
@end

/////////////////////////LTSTextMessage

@interface LTSTextMessage : NSObject

@property (nonatomic, retain) NSString *messageId;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) LTSTimestamp timestamp;
@property (nonatomic, retain) LTSEmployeeId senderId;

- (id) initWithId: (NSString *) messageId
             text: (NSString *) text
        timestamp: (LTSTimestamp) timestamp
           sender: (LTSEmployeeId) senderId;

- (BOOL)messageIdIsSet;
- (BOOL)textIsSet;
- (BOOL)timestampIsSet;
- (BOOL)senderIsSet;
@end



/////////////////////////LTSFileMessage

@interface LTSFileMessage : NSObject

@property (nonatomic, retain) NSString *messageId;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) LTSUrl url;
@property (nonatomic, retain) LTSTimestamp timestamp;
@property (nonatomic, retain) LTSEmployeeId senderId;

- (id) initWithId: (NSString *) messageId
             text: (NSString *) text
        timestamp: (LTSTimestamp) timestamp
              url: (LTSUrl) url
           sender: (LTSEmployeeId) senderId;

- (BOOL)messageIdIsSet;
- (BOOL)textIsSet;
- (BOOL)timestampIsSet;
- (BOOL)senderIsSet;
- (BOOL)urlIsSet;
@end



/////////////////////////LTSTypingMessage

@interface LTSTypingMessage : NSObject

@property (nonatomic, retain) NSString *text;

- (id) initWithText: (NSString *) text;

- (BOOL)textIsSet;
@end



/////////////////////////LTSHoldMessageMessage

@interface LTSHoldMessage : NSObject

@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) LTSTimestamp timestamp;

- (id) initWithText: (NSString *) text timestamp: (LTSTimestamp) timestamp;

- (BOOL)textIsSet;
- (BOOL)timestampIsSet;
@end

/////////////////////////LTSVote

//@interface LTSVote : NSObject
//
//@property (nonatomic) int voteType;
//@property (nonatomic, retain) NSString * message;
//
//- (id) initWithVoteType: (LTSVoteType) voteType message: (NSString *) message;
//- (BOOL) messageIsSet;
//@end

/////////////////////////LTSDialogAttributes

@interface LTSAbuse: NSObject
@property (nonatomic, retain) NSString * contact;
@property (nonatomic, retain) NSString * message;

- (id)initWithContact:(NSString *)contact message:(NSString *)message;
- (BOOL)contactIsSet;
- (BOOL)messageIsSet;

@end

@interface LTSDialogAttributes : NSObject

@property (nonatomic, retain) LTSOptions visible;
@property (nonatomic, retain) LTSOptions hidden;

- (id) initWithVisible: (LTSOptions) visible hidden: (LTSOptions) hidden;

@end
