//
//  ViewController.m
//  Rumtime
//
//  Created by wuhaiyang on 16/8/24.
//  Copyright © 2016年 wuhaiyang. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"
#import "Fruit.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "ArchivedObject.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor grayColor];
    
    
//******** 1、类真是存在，结果返回类名； 2、类不是真实存在，返回nil；
    const char *className = class_getName([Person class]);
    NSLog(@"%s", className); // Person
    
    const char *className1 = class_getName(NSClassFromString(@"Animal"));
    NSLog(@"%s", className1); // nil
    
    NSLog(@"分割线--------------------------");
    
//******** 1、存在父类，则返回父类；2、这个类为根类，返回null; 3、类不存在，返回null；
    Class superClass = class_getSuperclass([Person class]);
    NSLog(@"%@", superClass); //NSObject
    
    Class superClass1 = class_getSuperclass([NSObject class]);
    NSLog(@"%@", superClass1); //(null)
    
    Class superClass2 = class_getSuperclass(NSClassFromString(@"Animal"));
    NSLog(@"%@", superClass2); //(null)
    
    NSLog(@"分割线--------------------------");
    
//******* 1、修改某个类的父类，虽然官方禁止使用，但是仍然可以使用！ Person 父类由 NSObject 修改为  Fruit
    Class newSuperClass = class_setSuperclass([Person class], [Fruit class]);
    NSLog(@"%@--%@", newSuperClass, class_getSuperclass([Person class])); //NSObject--Fruit
    
    NSLog(@"分割线--------------------------");
    
//******* 1、判断某个类是不是metaClass，元类？； 2、NSObject 、不存在的类为NO；
    
    BOOL isMetaClass = class_isMetaClass([Person class]);
    NSLog(@"%d", isMetaClass); // 0  不是
    
    BOOL isMetaClass1 = class_isMetaClass([NSObject class]);
    NSLog(@"%d", isMetaClass1); // 0  不是
    
    BOOL isMetaClass2 = class_isMetaClass([NSClassFromString(@"Animal") class]);
    NSLog(@"%d", isMetaClass2);// 0  不是
    
    NSLog(@"分割线--------------------------");
    
//******* 1、获取一个类的实例大小，单位为字节bytes；2、NSObject 为 8 ； 3、不存在的类为 0 ；4、真实存在的类根据类而有所不同
    size_t size = class_getInstanceSize([Person class]);
    NSLog(@"%zu", size); // 24
    
    size_t size1 = class_getInstanceSize([NSObject class]);
    NSLog(@"%zu", size1); // 8
    
    size_t size2 = class_getInstanceSize([NSClassFromString(@"Animal") class]);
    NSLog(@"%zu", size2); // 0
    
    NSLog(@"分割线--------------------------");
    
//*******
#warning !!!
//    Person *person = [[Person alloc] init];
//    person.age = 100;
//    person.name = @"jack";
//    NSString *varName = [NSString stringWithFormat:@"person"];
//    const char *name = "age";
//    Ivar instanceVar = class_getInstanceVariable([Person class], name);
//    NSLog(@"%@", instanceVar);
//    
//    
//    NSString *varNameOne = [NSString stringWithFormat:@"age"];
//    const char *nameOne = "age";
//    Ivar classVar = class_getClassVariable([Person class], nameOne);
//    NSLog(@"%@", classVar);
//    
//    BOOL addIvarResult = class_addIvar([Person class], <#const char *name#>, <#size_t size#>, <#uint8_t alignment#>, <#const char *types#>)
    
    NSLog(@"分割线--------------------------");
    
    
//******* 1、获取类的实例所有的成员变量；2、带下划线的_age；
    unsigned int outCount = 0;
    Ivar *ivars = class_copyIvarList([Person class], &outCount);  // age   name
    for (int i = 0; i < outCount; i ++) {
        Ivar ivar = ivars[i];
        const char *ivarName = ivar_getName(ivar);
        NSLog(@"%p--%s", ivar, ivarName); // 0x102237478--_age   0x102237498--_name
    }
    NSLog(@"%d", outCount); // 2
    
    NSLog(@"分割线--------------------------");
    
//*******
//    const char *ivarLayout = class_getIvarLayout([Person class]);
//    NSLog(@"%s", ivarLayout);
    
//    class_setIvarLayout(<#__unsafe_unretained Class cls#>, <#const uint8_t *layout#>)
    
    
//******* 1、获取类的给定名称的属性；2、属性不存在，结果为空；3、类不存在，结果为空；
    const char *name = "age";
    objc_property_t property = class_getProperty([Person class], name);
    NSLog(@"%p", property); // 0x101c7f4e8
    
    objc_property_t property1 = class_getProperty([NSObject class], name);
    NSLog(@"%p", property1); // 0x0
    
    objc_property_t property2 = class_getProperty(NSClassFromString(@"Animal"), name);
    NSLog(@"%p", property2); // 0x0
    
    NSLog(@"分割线--------------------------");
    
    
//******* 1、获取类的属性；2、不带下划线age；
    unsigned int propertyCount = 0 ;
    objc_property_t *propertys = class_copyPropertyList([Person class], &propertyCount);
    for (int i = 0; i < propertyCount; i ++) {
        objc_property_t property = propertys[i];
        const char *propertyName = property_getName(property);
        const char *attributes = property_getAttributes(property);
        NSLog(@"%s---%s", propertyName, attributes); //age---Ti,N,V_age   name---T@"NSString",C,N,V_name
    }
    NSLog(@"%d", propertyCount); // 2
    
    NSLog(@"分割线--------------------------");
    
//****** 1、获取类的方法列表； 2、Method SEL ； 3、 给方法设置新的实现；4、交换两个方法的实现；
    Person *personTest = [[Person alloc] init];
    [personTest run];  // run--run--run--run--run--run--run--run--run
    [personTest eat];  // eat--eat--eat--eat--eat--eat--eat--eat--eat
//    IMP imp1;
//    IMP imp2;

    Method method1 = NULL;
    Method method2 = NULL;
    
    unsigned int methodCount = 0;
    Method *methods = class_copyMethodList([Person class], &methodCount);
    for (int i = 0 ; i < methodCount; i ++) {
        Method method = methods[i];
        SEL selMethodName = method_getName(method);
        IMP impMethod = method_getImplementation(method);

        const char *name = sel_getName(selMethodName);
        NSLog(@"%s", name); // eat run age setAge name setName .cxx_destruct
        
        //        id impBlock = imp_getBlock(impMethod);
        //        struct objc_method_description *descri = method_getDescription(method);
        //        NSLog(@"%s", descri);
        //        imp_implementationWithBlock()
        
        NSString *stringName = [NSString stringWithUTF8String:name];
        if ([stringName isEqualToString:@"run"]) {
            method1 = method;
        }
        if ([stringName isEqualToString:@"eat"]) {
            method2 = method;
        }
        method_exchangeImplementations(method1, method2);
        
    }
    
    [personTest run]; // eat--eat--eat--eat--eat--eat--eat--eat--eat
    [personTest eat]; // run--run--run--run--run--run--run--run--run
    
    NSLog(@"%d", methodCount); // 7
    
    NSLog(@"分割线--------------------------");
    
//******** 1、获取所有的类的列表；后续可以根据类名进行判断获取的类是不是所需要的类；
    unsigned int classCount = 0;
    Class *classes = objc_copyClassList(&classCount);
    for (int i = 0; i < classCount; i ++) {
        
        
    }
    NSLog(@"%d", classCount); // 4208
    
   NSLog(@"分割线--------------------------");
    
//******* 1、给某个对象绑定联系，key-value；2、联系不是属性，也不是成员变量，可以理解为键值对；
    Person *personObject = [[Person alloc] init];
    const void *key = "height";
    id value = @"175";
    objc_setAssociatedObject(personObject, key, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    id valu = objc_getAssociatedObject(personObject, key);
    NSLog(@"%@", valu); // 175
    
    unsigned int propertyCount10 = 0 ;
    objc_property_t *propertys10 = class_copyPropertyList([Person class], &propertyCount10);
    NSLog(@"%d", propertyCount10); //2
    
    NSLog(@"分割线--------------------------");
    
//********
    Person *personTemp = [[Person alloc] init];
    SEL sel = sel_getUid("alloc");
//    objc_msgSend(personTemp, sel);
    
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

    NSLog(@"touchsBegan-------");
    ArchivedObject *object = [[ArchivedObject alloc] init];
    object.age = 40;
    object.name = @"jack";
    object.height = 100.0;
    
    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fileName = [filePath stringByAppendingPathComponent:@"archive.plist"];

    [NSKeyedArchiver archiveRootObject:object toFile:fileName];
}


- (IBAction)archiver:(UIButton *)sender {
    
    ArchivedObject *object = [[ArchivedObject alloc] init];
    object.age = 40;
    object.name = @"jack";
    object.height = 100.0;
    
    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fileName = [filePath stringByAppendingPathComponent:@"archive.plist"];
    
    [NSKeyedArchiver archiveRootObject:object toFile:fileName];
    
}

- (IBAction)unarchiver:(id)sender {
    
    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fileName = [filePath stringByAppendingPathComponent:@"archive.plist"];
    
    ArchivedObject *object = [NSKeyedUnarchiver unarchiveObjectWithFile:fileName];
    
    NSLog(@"%d---%@----%f", object.age, object.name, object.height);
    
}

@end
