//
//  LTMobileSDKModel.h
//  LTMobileSDKModel
//
//  Created by Sergey on 17/11/14.
//  Copyright (c) 2014 LiveTex. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef int LTSVoteType;
typedef int LTSCapabilityType;
typedef int LTSOfflineConversationStatus;
typedef int LTSOfflineDirection;
typedef int LTSMessageType;

typedef NSString * LTSEmployeeId;
typedef NSString * LTSUrl;
typedef NSString * LTSToken;

/*!
  Статус оператора.
 
  Доступные значения:
 
  'online' - находиться в сети.
 
  'all' - любой статус.
*/

typedef NSString * LTSStatus;
typedef NSString * LTSTimestamp;
typedef NSString * LTSDepartmentId;
typedef NSString * LTSTextMessageId;
typedef NSMutableDictionary * LTSOptions;

@class LTSEmployee, LTSDepartment;

/*!
 Список доступных возможностей клиента.
 
 CHAT: поддержка начала чата и обмена сообщениями.

 FILES_RECEIVE: поддержка приема файлов.
 */

@interface LTSCapabilities : NSObject 
+ (LTSCapabilityType)CHAT;
+ (LTSCapabilityType)FILES_RECEIVE;
@end

/*!
  Тип оценки диалога.

  GOOD: диалог понравился.
 
  BAD: диалог не понравился.
 */

@interface LTSVoteTypes : NSObject
+ (LTSVoteType)GOOD;
+ (LTSVoteType)BAD;
@end

/*!
 Тип сообщения офлайн обращения.
 
 */

@interface LTSOfflienMessageTypes : NSObject
+ (LTSVoteType)FILE;
+ (LTSVoteType)TEXT;
@end

/*!
  Статус обращения
 
  OPEN - Открыто (можно с ним работать)
  CLOSE - Закрыто.
 */

@interface LTSOfflineConversationStatuses : NSObject
+ (LTSOfflineConversationStatus)CLOSE;
+ (LTSOfflineConversationStatus)OPEN;
@end

/*!
 Обращение клиента.
 
 employeeId: обращение с указанием конкретного оператора.

 departmentId: обращение с указанием конкретного департамента.
*/

@interface LTSConversation : NSObject
@property (nonatomic, retain) LTSEmployeeId employeeId;
@property (nonatomic, retain) LTSDepartmentId departmentId;

- (instancetype)initWithDepartment:(LTSDepartmentId) departmentId
                  employee:(LTSEmployeeId) employeeId;

- (BOOL)departmentIsSet;
- (BOOL)employeeIsSet;
@end



/*!
 Оператор.


id: уникальный идентификатор оператора.

status: актуальный статус оператора.

firstname: имя оператора.

lastname: фамилия оператора.

avatar: URL аватара оператора.

phone: телефон оператора.

email: email оператора.

options: опциональные аттрибуты оператора.
*/

@interface LTSEmployee : NSObject
@property (nonatomic, retain) LTSEmployeeId employeeId;
@property (nonatomic, retain) LTSStatus status;
@property (nonatomic, retain) NSString *firstname;
@property (nonatomic, retain) NSString *lastname;
@property (nonatomic, retain) LTSUrl avatar;
@property (nonatomic, retain) NSString *phone;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) LTSOptions options;

- (instancetype)initWithEmployeeId: (LTSEmployeeId) employeeId
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


/*!
Департамент - множестов операторов.

departmentId: уникальный идентификатор депертамента.

name: имя департамента.

options: опциональные аттрибуты департамента.
 */

@interface LTSDepartment : NSObject
@property (nonatomic, retain) NSString *departmentId;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) LTSOptions options;

- (instancetype)initWithId:(NSString *) departmentId
            name:(NSString *) name
         options:(LTSOptions) options;

- (BOOL)departmentIdIsSet;
- (BOOL)nameIsSet;
- (BOOL)optionsIsSet;

@end



/*!
Состояние интерфейса клиента сервиса диалога.
 
conversation: обращение клиента. Если обращение отсутствует,
  то интерфейс в состоянии NoConversation, если обращение присутствует,
  то возможно одно из состояний: ConversationQueued или ConversationActive.
 
employee: оператор назначенный диалогу. Если оператора есть,
  то состояние ConversationActive, если оператора нет, то возможно
  одно из состояний: NoConversation или ConversationQueued.
 */

@interface LTSDialogState : NSObject

@property (nonatomic, retain) LTSConversation *conversation;
@property (nonatomic, retain) LTSEmployee *employee;

- (instancetype)initWithConversation:(LTSConversation *) conversation
                  employee:(LTSEmployee *) employee;

- (BOOL)conversationIsSet;
- (BOOL)employeeIsSet;
@end

/*!
Текстовое сообещение.

id: уникалный идентификатор сообщения.

text: текст сообщения.

timestamp: время создания удерживающего сообщения.

sender: источник сообщения. Если поле присутствует, то сообщение
  от оператора, в ином случае сообщение от посетителя.
*/

@interface LTSTextMessage : NSObject

@property (nonatomic, retain) NSString *messageId;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) LTSTimestamp timestamp;
@property (nonatomic, retain) LTSEmployeeId senderId;

- (instancetype) initWithId: (NSString *) messageId
             text: (NSString *) text
        timestamp: (LTSTimestamp) timestamp
           sender: (LTSEmployeeId) senderId;

- (BOOL)messageIdIsSet;
- (BOOL)textIsSet;
- (BOOL)timestampIsSet;
- (BOOL)senderIsSet;
@end


/*!
Сообещение передачи файла.

id: уникалный идентификатор сообщения.

text: текст сообщения.
 
timestamp: время создания удерживающего сообщения.
 
url: URL переданного файла.
 
sender: источник сообщения. Если поле присутствует, то сообщение
  от оператора, в ином случае сообщение от посетителя.
*/

@interface LTSFileMessage : NSObject

@property (nonatomic, retain) NSString *messageId;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) LTSUrl url;
@property (nonatomic, retain) LTSTimestamp timestamp;
@property (nonatomic, retain) LTSEmployeeId senderId;

- (instancetype) initWithId: (NSString *) messageId
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



/*!
Сообщение оповещения о наборе текста.

text: набранный текст.
 */

@interface LTSTypingMessage : NSObject

@property (nonatomic, retain) NSString *text;

- (instancetype) initWithText: (NSString *) text;

- (BOOL)textIsSet;
@end



/*!
Удерживающее сообщение.

text: текст удерживающего сообщения.
 
timestamp: время создания удерживающего сообщения.
 */

@interface LTSHoldMessage : NSObject

@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) LTSTimestamp timestamp;

- (instancetype) initWithText: (NSString *) text timestamp: (LTSTimestamp) timestamp;

- (BOOL)textIsSet;
- (BOOL)timestampIsSet;
@end

/*!
Жалоба.

contact: контактные данные.

message: текст жалобы.
 */

@interface LTSAbuse: NSObject
@property (nonatomic, retain) NSString * contact;
@property (nonatomic, retain) NSString * message;

- (instancetype)initWithContact:(NSString *)contact message:(NSString *)message;
- (BOOL)contactIsSet;
- (BOOL)messageIsSet;

@end


/**
 *  Класс `LTSDialogAttributes` определяет данные, которые будут переданы оператору при создании обращения.
 */
@interface LTSDialogAttributes : NSObject

/**
 *  Данные, доступные для отображения в пульте оператора.
 */
@property(nonatomic, retain) LTSOptions visible;

/**
 *  Данные, недоступные для отображения в пульте оператора.
 */
@property(nonatomic, retain) LTSOptions hidden;

/**
 *  Определяет будут ли переданы оператору по умолчанию системные данные:
 *  Модель устройства, ОС, Версия приложения, Тип соединения, Оператор связи. По умолчанию `true`.
 */
@property(nonatomic, assign) BOOL useDefaultOptions;

- (instancetype)initWithVisible:(LTSOptions)visible hidden:(LTSOptions) hidden;

@end

/*!
 Структура для загрузки файлов
 fileData : содержимое файла,
 name : имя файла,
 fileExtension : расширение файла,
 mimeType : тип файла
 */

@interface LTSFile : NSObject

@property (nonatomic, retain) NSData* fileData;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* fileExtension;
@property (nonatomic, retain) NSString* mimeType;

- (instancetype) initWithData: (NSData *) fileData
                     fileName: (NSString *) name
                fileExtension: (NSString *) ext
                     mimeType: (NSString *) mimeType;

@end


/*!
 Структура обращения по оффлайн каналу
 conversationId : идентификатор обращения
 firstMessage : текст последнего сообщения
 status : статус обращения типа LTSOfflineConversationStatus
 visitorId : идентификатор пользователя
 creationTime : время создания
 currentOperatorId : идентификатор текущего оператора
 */

@interface LTSOfflineConversation : NSObject

@property (nonatomic, retain) NSString * conversationId;
@property (nonatomic, retain) NSString * lastMessage;
@property (nonatomic, assign) LTSOfflineConversationStatus status;
@property (nonatomic, retain) NSString * creationTime;
@property (nonatomic, retain) NSString * updateTime;
@property (nonatomic, retain) NSString * visitorId;
@property (nonatomic, retain) NSString * currentOperatorId;

- (instancetype) initWithId: (NSString *) conversetionId
               firstMessage: (NSString *) firstMessage
                     status: (LTSOfflineConversationStatus)status
               creationTime: (NSString *) created
                 updateTime: (NSString *) update
                  visitorId: (NSString *) visitorId
          currentOperatorId: (NSString *) currentOperatorId;

@end

/*!
 Сообщение в оффлайн обращении
 sender : тип данных LTSEmployeeId, если ноль, то сообщения от посетителя.
 message : текст сообщения
 creationTime : время создания
 messageId : идентификатор сообщения
 */

@interface LTSOfflineMessage: NSObject

@property (nonatomic, retain) NSString * messageId;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, assign) LTSMessageType type;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSString * creationTime;
@property (nonatomic, retain) LTSEmployeeId sender;

- (instancetype) initWithId: (NSString *) messageId
                    message: (NSString *) message
                       type: (LTSMessageType) type
                        url: (NSString *) url
                 created_at: (NSString *) creationTime
                     sender: (LTSEmployeeId) sender;
@end

/*!
 Набор контактных данных для создания оффлайн обращения. Возможно частичное заполнение.
 name : имя пользователя
 phone : контактный телефон пользователя
 email : почтовый адрес пользователя
 */

@interface LTSOfllineVisitorContacts : NSObject
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * email;

@end
