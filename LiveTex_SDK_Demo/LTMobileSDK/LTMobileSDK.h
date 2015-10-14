//
//  LTMobileSDK.h
//  LTMobileSDK
//
//  Created by Sergey on 09/09/14.
//  Copyright (c) 2014 LiveTex. All rights reserved.
//

//#define TEST

#import <Foundation/Foundation.h>
#import "LTSDKModel.h"

#define kLivetexPersistStorage @"livetex.storage.ref"

/*!
 Протокол делегата для работы с нотификациями сервиса нотификаций диалога
 
 @warning Методы делегата вызываются в GCD-очереди, передаваемой при инициализации объекта SDK с помощью поля delegateQueue класса LTMobileSDKInitializationParams. По умолчанию - это последовательная очередь, ассоциированая с главным потоком и подготавливается вызовом функции библиотеки libdispatch dispatch_get_main_queue(), в этом случае методы делегата выполняется синхронно на главном потоке относительно параллельного потока рабочей последовательной
 */

@protocol LTMobileSDKNotificationHandlerProtocol <NSObject>

/*!
 Бан посетителя с указанием сообщения причины.
 */
- (void)ban: (NSString *) message;
/*!
 Обновление состояния диалога
 */
- (void)updateDialogState: (LTSDialogState *) state;
/*!
 Передача фаила
 */
- (void)receiveFileMessage: (LTSFileMessage *) message;
/*!
 Новое сообщение пользователю
 */
- (void)receiveTextMessage: (LTSTextMessage *) message;
/*!
 Подтверждение набора сообщения
 */
- (void)confirmTextMessage: (LTSTextMessageId) message;
/*!
 Удерживающее сообщение
 */
- (void)receiveHoldMessage: (LTSHoldMessage *) message;
/*!
 Получение нотификации о наборе текста
 */
- (void)receiveTypingMessage: (LTSTypingMessage *) message;
/*!
 Получение нотификации об оффлайн сообщении в оффлайн обращении
 */
- (void)receiveOfflineMessage:(NSString *)conversationId message:(LTSOfflineMessage *) message;
/*!
 Обработка ошибки при работе сервера нотификаций.  Возможно использовать для перезапуска SDK
 */
- (void)notificationListenerErrorOccured: (NSException *) error;

@end




/*!
 Класс, экземпляр которого является объектом для инициализации SDK
 */
@interface LTMobileSDKInitializationParams : NSObject
/*!
 Адрес сервиса авторизации LiveTex
 */
@property(nonatomic, strong) NSString *livetexUrl;
/*!
 Устанавливает SDK Key для работы с LiveTex
 */
@property(nonatomic, strong) NSString *sdkKey;
/*!
 Устанавливает ApplicationId LiveTex
 */
@property(nonatomic, strong) NSString *applicationId;
/*!
 Устанавливает token пользователя LiveTex. Опционально. По умолчанию используется токен уже находящийся в кеше SDK, если его нет, то система выдает новый токен.
 */
@property(nonatomic, strong) NSString *token;

/*!
 Устанавливает APN deviceId пользователя LiveTex. Опционально. Используется для раоботы с сервисом APN
 */

@property(nonatomic, strong) NSString *customToken;

/*!
 Опционально. Используется для раоботы с кастомным сервисом сервисом APN
 */

@property(nonatomic, strong) NSString *APNDeviceId;
/*!
 Реализуемые возможности чата. Передача фаилов, диалог, и тп.
 */
@property(nonatomic, strong) NSMutableArray *capabilities;
/*!
 GCD-очередь в которой будет выполняться callback-блоки для запросов
 SDK отностительно параллельного потока рабочей очереди SDK.
 По умолчанию - это последовательная очередь, ассоциированая с главным 
 потоком и подготавливается вызовом функции библиотеки
 libdispatch dispatch_get_main_queue() 
 */
@property(nonatomic, strong) dispatch_queue_t callbackQueue;
/*!
 GCD-очередь в которой будет выполняться методы делегата сервиса нотификаций SDK
 отностительно параллельного потока рабочей очереди SDK.
 По умолчанию - это последовательная очередь, ассоциированая с главным
 потоком и подготавливается вызовом функции библиотеки libdispatch dispatch_get_main_queue()
 */
@property(nonatomic, strong) dispatch_queue_t delegateQueue;
@end




/*!
@warning Запросы выполняются асинхронно относительно вызывающего потока в параллельном потоке рабочей последовательной
очереди SDK (serial queue) с использованием механизма Grand Central Dispatch и библиотеки libdispatch. Блоки success и failure вызываются в GCD-очереди, передаваемой при инициализации объекта SDK с помощью поля callbackQueue класса LTMobileSDKInitializationParams. По умолчанию - это последовательная очередь, ассоциированая с главным потоком и подготавливается вызовом функции библиотеки libdispatch dispatch_get_main_queue()
 */

@interface LTMobileSDK : NSObject

/*!
 Делегат для получения уведомлений сервисов offline/online обращений при рабочем состоянии SDK. Делегат должен реализовать методы LTMobileSDKNotificationHandlerProtocol
 */

@property(nonatomic, weak) id <LTMobileSDKNotificationHandlerProtocol> delegate;

#pragma mark starting

- (instancetype)initWithParams:(LTMobileSDKInitializationParams*)params;

- (void)runWithSuccess:(void(^)(LTSToken token))success
               failure:(void(^)(NSException *exeption))failure;

#pragma mark outer buisnes interfaces
#pragma mark dialog service

/*!
 Запрос диалога с конкретным оператором.
 
 @result Вызов колбек-блока соответствующего результату. При успешном выполнении запроса вызывается
 колбек-блок success, в противном случае вызывается failure, параметром у которого явлется объект типа NSExeption
 пойманый при выполнии операции в параллельном потоке очереди SDK.
*/

- (void)requestWithSuccess:(void(^)(LTSDialogState *state))success
                   failure:(void(^)(NSException *ChatException))failure;

/*!
 Запрос диалога с конкретным оператором.
 
 @param attributes данные сопутствующие диалогу.
 
 @result Вызов колбек-блока соответствующего результату. При успешном выполнении запроса вызывается
 колбек-блок success, параметром у которого является объект типа LTSDialogState - состояние текущего обращения, в противном случае вызывается failure, параметром у которого явлется объект типа NSExeption
 пойманый при выполнии операции в параллельном потоке очереди SDK. 
 ChatException ошибка сервиса чата. Может возникать в случае неверных атрибутов диалога.
 */

- (void)requestWithDialogAttributes:(LTSDialogAttributes*)atrributes
                            success:(void(^)(LTSDialogState *state))success
                            failure:(void(^)(NSException *ChatException))failure;

/*!
 Запрос диалога с конкретным оператором.

 @param mOperator оператор, к которым необходимо начать диалог.

 @result Вызов колбек-блока соответствующего результату. При успешном выполнении запроса вызывается
 колбек-блок success, параметром у которого является объект типа LTSDialogState - состояние текущего обращения, в противном случае вызывается failure, параметром у которого явлется объект типа NSExeption
 пойманый при выполнии операции в параллельном потоке очереди SDK. 
 ChatException ошибка сервиса чата. Может возникать в
 случае неверных атрибутов диалога или при указании невалидного оператора.
 
 */

/*! Очистка кэша с сессией
 */
-(void)clearSession;

- (void)requestWithEmployee:(LTSEmployeeId)employeeId
                    success:(void(^)(LTSDialogState *state))success
                    failure:(void(^)(NSException *ChatException))failure;

/*!
 Запрос диалога с конкретным оператором.

 @param mOperator оператор, к которым необходимо начать диалог.

 @param attributes данные сопутствующие диалогу.
 
 @result Вызов колбек-блока соответствующего результату. При успешном выполнении запроса вызывается
 колбек-блок success, параметром у которого является объект типа LTSDialogState - состояние текущего обращения, в противном случае вызывается failure, параметром у которого явлется объект типа NSExeption
 пойманый при выполнии операции в параллельном потоке очереди SDK. 
 ChatException ошибка сервиса чата. Может возникать в
 случае неверных атрибутов диалога или при указании невалидного оператора.
 
 */

- (void)requestWithEmployee:(LTSEmployeeId)employeeId
           dialodAttributes:(LTSDialogAttributes*)atrributes
                    success:(void(^)(LTSDialogState *state))success
                    failure:(void(^)(NSException *ChatException))failure;

/*!
 Запрос диалога с операторами указанного департамента.

 @param department департамент, с оператом которого необходимо начать диалог.

 @result Вызов колбек-блока соответствующего результату. При успешном выполнении запроса вызывается
 колбек-блок success, параметром у которого является объект типа LTSDialogState - состояние текущего обращения, в противном случае вызывается failure, параметром у которого явлется объект типа NSExeption
 пойманый при выполнии операции в параллельном потоке очереди SDK. 
 ChatException ошибка сервиса чата. Может возникать при указании невалидного депертамента.
 
 */

- (void)requestWithDepartment:(LTSDepartmentId)departmentId
                      success:(void(^)(LTSDialogState *state))success
                      failure:(void(^)(NSException *ChatException))failure;

/*!
 Запрос диалога с операторами указанного департамента.

 @param department департамент, с оператом которого необходимо начать диалог.

 @param attributes данные сопутствующие диалогу.
 
 @result Вызов колбек-блока соответствующего результату. При успешном выполнении запроса вызывается
 колбек-блок success, параметром у которого является объект типа LTSDialogState - состояние текущего обращения, в противном случае вызывается failure, параметром у которого явлется объект типа NSExeption
 пойманый при выполнии операции в параллельном потоке очереди SDK. 
 ChatException ошибка сервиса чата. Может возникать в
 случае неверных атрибутов диалога или при указании невалидного депертамента.

 */

- (void)requestWithDepartment:(LTSDepartmentId)departmentId
             dialodAttributes:(LTSDialogAttributes*)atrributes
                      success:(void(^)(LTSDialogState *state))success
                      failure:(void(^)(NSException *ChatException))failure;

/*!
 Прекращение диалога с собеседником.
 
 @result Вызов колбек-блока соответствующего результату. При успешном выполнении запроса вызывается
 колбек-блок success, параметром у которого является объект типа LTSDialogState - состояние текущего обращения, в противном случае вызывается failure, параметром у которого явлется объект типа NSExeption
 пойманый при выполнии операции в параллельном потоке очереди SDK. 
 ChatException ошибка сервиса чата. Может возникать в
   случае отсутствия текущего диалога.

 */

- (void)closeWithSuccess:(void(^)(LTSDialogState *state))success
                 failure:(void(^)(NSException *ChatException))failure;

/*!
 ПОценка диалога с собеседником.
 
 @param vote оценка собеседника.
 
 @result Вызов колбек-блока соответствующего результату. При успешном выполнении запроса вызывается
 колбек-блок success, параметром у которого является объект типа LTSDialogState - состояние текущего обращения, в противном случае вызывается failure, параметром у которого явлется объект типа NSExeption
 пойманый при выполнии операции в параллельном потоке очереди SDK. 
 ChatException ошибка сервиса чата. Может возникать в
   случае отсутствия текущего диалога.
 */

- (void)voteWithVote:(LTSVoteType)vote
             success:(void(^)())success
             failure:(void(^)(NSException *ChatException))failure;


/*!
 Жалоба на диалог с собеседником.
 
 @param abuse данные жалобы
 
 @result Вызов колбек-блока соответствующего результату. При успешном выполнении запроса вызывается
 колбек-блок success, параметром у которого является объект типа LTSDialogState - состояние текущего обращения, в противном случае вызывается failure, параметром у которого явлется объект типа NSExeption
 пойманый при выполнии операции в параллельном потоке очереди SDK.
 ChatException ошибка сервиса чата. Может возникать в
 случае отсутствия текущего диалога.
 */

- (void)abuseWithAbuse:(LTSAbuse *)abuse
             success:(void(^)())success
             failure:(void(^)(NSException *ChatException))failure;

/*!
 Оповещение о наборе текста.
 
 @param message набранное сообщение.
 
 @result Вызов колбек-блока соответствующего результату. При успешном выполнении запроса вызывается
 колбек-блок success, в противном случае вызывается failure, параметром у которого явлется объект типа NSExeption
 пойманый при выполнии операции в параллельном потоке очереди SDK. 
 ChatException ошибка сервиса чата. Может возникать в
   случае отсутствия текущего диалога.

 */

- (void)typingWithTypingMessage:(LTSTypingMessage*)message
                        success:(void(^)())success
                        failure:(void(^)(NSException *ChatException))failure;

/*!
 Отправка текстового сообщения.
 
 @param message текст сообщения.
 
 @result Вызов колбек-блока соответствующего результату. При успешном выполнении запроса вызывается
 колбек-блок success, в противном случае вызывается failure, параметром у которого явлется объект типа NSExeption
 пойманый при выполнии операции в параллельном потоке очереди SDK. 
 message созданое сервером сообщение.
 ChatException ошибка сервиса чата. Может возникать в
   случае отсутствия текущего диалога.
 */

- (void)sendMessage:(NSString*)text
            success:(void(^)(LTSTextMessage *message))success
            failure:(void(^)(NSException *ChatException))failure;

/*!
 Получение истории сообщений диалога.
 
 @param limit количество запрашиваемых сообщений из истории.
 *
 @param offset количество пропускаемых сообщений истории.
 
 @result Вызов колбек-блока соответствующего результату. При успешном выполнении запроса вызывается
 колбек-блок success, в противном случае вызывается failure, параметром у которого явлется объект типа NSExeption
 пойманый при выполнии операции в параллельном потоке очереди SDK. 
 messages список сообщений истории чата
 ChatException ошибка сервиса чата.
 
 */

- (void)messageHistory:(int16_t)limit
                offset:(int16_t)offset
               success:(void(^)(NSArray *messages))success
               failure:(void(^)(NSException *ChatException))failure;


/*!
 Получение текущего состояния интерфейса клиента сервиса диалога.
 
 @result Вызов колбек-блока соответствующего результату. При успешном выполнении запроса вызывается
 колбек-блок success, в противном случае вызывается failure, параметром у которого явлется объект типа NSExeption
 пойманый при выполнии операции в параллельном потоке очереди SDK.
 state текущее состояние интерфейса клиента сервиса диалога.
 ChatException ошибка сервиса чата.
 
 */

- (void)getStateWithSuccess:(void(^)(LTSDialogState *state))success
                    failure:(void(^)(NSException *ChatException))failure;

#pragma mark presence service

/*!
 Получение списка операторов с указанным статусом.
 
 @param status интересующий статус.
 
 @result Вызов колбек-блока соответствующего результату. При успешном выполнении запроса вызывается
 колбек-блок success, в противном случае вызывается failure, параметром у которого явлется объект типа NSExeption
 пойманый при выполнии операции в параллельном потоке очереди SDK. 
 operators список операторов с указанным статусом.
 ChatException ошибка сервиса чата.
 
 */

- (void)getEmployees:(LTSStatus)status
             success:(void(^)(NSArray *operators))success
             failure:(void(^)(NSException *error))failure;

/*!
 Получение списка департаментов с указанным статусом.
 
 @param status интересующий статус.
 
 @result Вызов колбек-блока соответствующего результату. При успешном выполнении запроса вызывается
 колбек-блок success, в противном случае вызывается failure, параметром у которого явлется объект типа NSExeption
 пойманый при выполнии операции в параллельном потоке очереди SDK. 
 departments список департаментов с указанным статусом.
 ChatException ошибка сервиса чата.
 
 */

- (void)getDepartments:(LTSStatus)status
               success:(void(^)(NSArray *departments))success
               failure:(void(^)(NSException *error))failure;

/*!
 Получение списка операторов для указанного департамента.
 
 @param department депертамент, операторы которого будут получены
 
 @result Вызов колбек-блока соответствующего результату. При успешном выполнении запроса вызывается
 колбек-блок success, в противном случае вызывается failure, параметром у которого явлется объект типа NSExeption
 пойманый при выполнии операции в параллельном потоке очереди SDK. 
 operators список операторов для указанного депертамента.
 ChatException ошибка сервиса чата.
 
 */

- (void)getDepartmentEmployees:(LTSDepartment *)department
                       success:(void(^)(NSArray *operators))success
                       failure:(void(^)(NSException *error))failure;

#pragma mark visitor service

/*!
 Установка имени посетителя.
 
 @param name имя посетителя.
 
 @result Вызов колбек-блока соответствующего результату. При успешном выполнении запроса вызывается
 колбек-блок success, в противном случае вызывается failure, параметром у которого явлется объект типа NSExeption
 пойманый при выполнии операции в параллельном потоке очереди SDK. 
 ChatException ошибка сервиса чата.
 
 */

- (void)setVisitorName:(NSString *)name
             success:(void(^)())success
             failure:(void(^)(NSException *error))failure;


/*!
 Подтверждение получения сообщения.
 
 @param textMessageId индетификатор полученного сообщеиня.
 
 @result Вызов колбек-блока соответствующего результату. При успешном выполнении запроса вызывается
 колбек-блок success, в противном случае вызывается failure, параметром у которого явлется объект типа NSExeption
 пойманый при выполнии операции в параллельном потоке очереди SDK.
 ChatException ошибка сервиса чата.
 
 */

- (void)confirmTextMessageWithId:(LTSTextMessageId)textMessageId
               success:(void(^)())success
               failure:(void(^)(NSException *error))failure;



/*!
 Остановка SDK, прекращение работы с realtime нотификациями. После вызова этого метода следует перезапустить sdk методом runWithSuccess
 */

- (void)stop;

/*!
 Отправка оффлайн сообщения для оффлайн обращения.
 
 @param text текст сообщения
 @param conversationId идентификатор оффлайн диалога
 @result Вызов колбек-блока соответствующего результату. При успешном выполнении запроса вызывается
 колбек-блок success, в противном случае вызывается failure, параметром у которого явлется объект типа NSExeption
 пойманый при выполнии операции в параллельном потоке очереди SDK.
 ChatException ошибка сервиса чата.
 
 */

- (void)sendOfflineMessageWithText:(NSString *)text
                    conversationId:(NSString *)conversationId
                           success:(void(^)())success
                           failure:(void(^)(NSException *ChatException))failure;

/*!
 Создание оффлайн обращения с указанием контактных данных.
 
 @param LTSOfllineVisitorContacts структура контактов для посетителя, поля струткуры опциональны
 @result Вызов колбек-блока соответствующего результату. При успешном выполнении запроса вызывается
 колбек-блок success, в противном случае вызывается failure, параметром у которого явлется объект типа NSExeption
 пойманый при выполнии операции в параллельном потоке очереди SDK.
 ChatException ошибка сервиса чата.
 
 */

- (void)createOfflineConversationForVisitor:(LTSOfllineVisitorContacts *)contacts
                            forDepartmentId:(NSString *)depId
                                    success:(void(^)(NSString *conversationId))success
                                    failure:(void(^)(NSException *ChatException))failure;

/*!
 Получение списка оффлайн обращений для текщего авторизованного в сдк пользователя.
 
 @result Вызов колбек-блока соответствующего результату. При успешном выполнении запроса вызывается
 колбек-блок success с параметром conversations (список оффлайн обращений) для посетителя,
 тип данных одного элемента LTSOfflineConversation, в противном случае вызывается failure,
 параметром у которого явлется объект типа NSExeption пойманый при выполнии операции в параллельном потоке очереди SDK.
 ChatException ошибка сервиса чата.
 
 */
- (void)offlineConversationsListWithSuccess:(void(^)(NSArray *conversations))success
                                    failure:(void(^)(NSException *ChatException))failure;

/*!
 Получение списка оффлайн сообщений для оффлайн обращения.
 
 @param cid индетификатор оффлайн диалога
 @result Вызов колбек-блока соответствующего результату. При успешном выполнении запроса вызывается
 колбек-блок success с параметром messages (список оффлайн сообщений) для оффлайн обращения,
 тип данных одного элемента LTSOfflineMessage, в противном случае вызывается failure,
 параметром у которого явлется объект типа NSExeption
 пойманый при выполнии операции в параллельном потоке очереди SDK. 
 ChatException ошибка сервиса чата.
 
 */

- (void)messageListForConversationId:(NSString *)conversationId
                             success:(void(^)(NSArray *messages))success
                             failure:(void(^)(NSException *ChatException))failure;


/*!
 Отправка файла в режиме онлайн.
 
 */

- (void) uploadFileData: (LTSFile *) file
            recipientId: (NSString *) resId
                success: (void(^)()) success
                failure: (void(^)(NSException *ChatException)) failure;

/*- (void)uploadFileData:(NSData *)fileData
              fileName:(NSString *)name
         fileExtention:(NSString *)ext
              mimeType:(NSString *)type
           recipientID:(NSString *)resId
               success:(void(^)())success
               failure:(void(^)(NSException *ChatException))failure;*/


/*!
 Отправка файла в режиме оффлайн.
 
 */

-(void) uploadOfflineFileData:(LTSFile *) file
               conversationId:(NSString *) resId
                      success:(void(^)()) success
                      failure:(void(^)(NSException *ChatException)) failure;

/*- (void)uploadOfflineFileData:(NSData *)fileData
              fileName:(NSString *)name
         fileExtention:(NSString *)ext
              mimeType:(NSString *)type
           conversationId:(NSString *)resId
               success:(void(^)())success
               failure:(void(^)(NSException *ChatException))failure;*/
@end



