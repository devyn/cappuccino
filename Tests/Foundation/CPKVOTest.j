import <Foundation/CPKeyValueCoding.j>
import <Foundation/CPKeyValueObserving.j>

@implementation CPKVOTest : OJTestCase
{
    BOOL    _sawInitialObservation;
    BOOL    _sawPriorObservation;
    BOOL    _sawObservation;
    
    id      bob;
    id      obj;
    id      cs101;
    id      focus;
}

- (void)testAddObserver
{
    bob = [[PersonTester alloc] init];
    
    [bob addObserver:self forKeyPath:@"name" options:nil context:"testAddObserver"];
        
    [bob setValue:@"bob" forKey:@"name"];
    
    [self assertTrue: [bob valueForKey:@"name"] == @"set_bob" message: "valueForKey:'name' should be 'set_bob', was: "+[bob valueForKey:@"name"]];
    [self assertTrue: bob.name == @"set_bob" message: "bob.name should be 'set_bob', was: "+bob.name];
    [self assertTrue: _sawObservation message:"Never recieved an observation"];
}

- (void)testUnobservedKey
{
    bob = [[PersonTester alloc] init];
    
    [bob addObserver:self forKeyPath:@"name" options:nil context:"testUnobservedKey"];
        
    [bob setValue:@"555" forKey:@"phoneNumber"];
    
    [self assertTrue: [bob valueForKey:@"phoneNumber"] == @"555" message: "'phoneNumber' should be '555', was: "+[bob valueForKey:@"phoneNumber"]];
    [self assertFalse: _sawObservation message:"Should not have recieved an observation"];
}

- (void)testAddTwoObservers
{
    bob = [[PersonTester alloc] init];
    
    [bob addObserver:self forKeyPath:@"name" options:nil context:"testAddTwoObservers"];
    [bob addObserver:[CPObject new] forKeyPath:@"name" options:nil context:"testAddTwoObservers"];
        
    [bob setValue:@"bob" forKey:@"name"];
    
    [self assertTrue: [bob valueForKey:@"name"] == @"set_bob" message: "valueForKey:'name' should be bob, was: "+[bob valueForKey:@"name"]];
    [self assertTrue: bob.name == @"set_bob" message: "bob.name should be 'bob', was: "+bob.name];
    [self assertTrue: _sawObservation message:"Never recieved an observation"];
}

- (void)testDirectIVarObservation
{
    var bob = [[PersonTester alloc] init];
    
    [bob addObserver:self forKeyPath:@"phoneNumber" options:nil context:"testDirectIVarObservation"];
    
    [bob setValue:@"555" forKey:@"phoneNumber"];
    
    [self assertTrue: [bob valueForKey:@"phoneNumber"] == @"555" message: "valueForKey:'phoneNumber' should be '555', was: "+[bob valueForKey:@"phoneNumber"]];
    [self assertTrue: bob.phoneNumber == @"555" message: "bob.phoneNumber should be '555', was: "+bob.phoneNumber];
    [self assertTrue: _sawObservation message:"Never recieved an observation"];
}

- (void)testRemoveObserver
{
    bob = [[PersonTester alloc] init];
        
    [bob addObserver:self forKeyPath:@"name" options:nil context:"testRemoveObserver"];
    [bob addObserver:[CPString new] forKeyPath:@"name" options:nil context:"testRemoveObserver"];
    
    [bob removeObserver:self forKeyPath:@"name"];
    
    [bob setValue:@"bob" forKey:@"name"];
    
    [self assertTrue: [bob valueForKey:@"name"] == @"set_bob" message: "valueForKey:'name' should be bob, was: "+[bob valueForKey:@"name"]];
}

- (void)testRemoveOtherObserver
{
    bob = [[PersonTester alloc] init];
    obj = [CPString new];
        
    [bob addObserver:self forKeyPath:@"name" options:nil context:"testRemoveOtherObserver"];
    [bob addObserver:obj forKeyPath:@"name" options:nil context:"testRemoveOtherObserver"];
    
    [bob removeObserver:obj forKeyPath:@"name"];
    
    [bob setValue:@"bob" forKey:@"name"];
    
    [self assertTrue: [bob valueForKey:@"name"] == @"set_bob" message: "valueForKey:'name' should be bob, was: "+[bob valueForKey:@"name"]];
    [self assertTrue: _sawObservation message:"Never recieved an observation"];
}

- (void)testRemoveAllObservers
{
    bob = [[PersonTester alloc] init];
    obj = [CPArray new];
    obj2 = [CPString new];
        
    [bob addObserver:obj forKeyPath:@"name" options:nil context:"testRemoveAllObservers"];
    [bob addObserver:obj2 forKeyPath:@"name" options:nil context:"testRemoveAllObservers"];
    
    [bob removeObserver:obj forKeyPath:@"name"];
    [bob removeObserver:obj2 forKeyPath:@"name"];
    [bob removeObserver:nil forKeyPath:nil];
    
    [bob setValue:@"bob" forKey:@"name"];
    
    [self assertTrue: [bob valueForKey:@"name"] == @"set_bob" message: "valueForKey:'name' should be bob, was: "+[bob valueForKey:@"name"]];

}

- (void)testPriorObservationOption
{
    _sawPriorObservation = NO;
    
    bob = [[PersonTester alloc] init];
    
    [bob addObserver:self forKeyPath:@"name" options:CPKeyValueObservingOptionPrior context:"testPriorObservationOption"];

    [bob setValue:@"bob" forKey:@"name"];

    [self assertTrue: _sawPriorObservation message: "asked for CPKeyValueObservingOptionPrior but did not recieve corresponding notification"];
}

- (void)testInitialObservationOption
{
    _sawInitialObservation = NO;

    bob = [[PersonTester alloc] init];
    
    bob.name = "paul";    

    [bob addObserver:self forKeyPath:@"name" options:CPKeyValueObservingOptionInitial context:"testInitialObservationOption"];
    [bob removeObserver:self forKeyPath:@"name"];

    [bob setValue:@"bob" forKey:@"name"];

    [self assertTrue: _sawInitialObservation message: "asked for CPKeyValueObservingOptionInitial but did not recieve corresponding notification"];
}

- (void)testMultipartKey
{
    cs101 = [ClassTester new];
    bob = [PersonTester new];
    
    [cs101 setTeacher:bob];
    
    [cs101 addObserver:self forKeyPath:@"teacher.name" options:nil context:"testMultipartKey"];
    
    [bob setName:@"bob"];
    
    [self assertTrue:[cs101 valueForKeyPath:@"teacher.name"] == "set_bob" message:"teacher.name should be: set_bob, was: "+[cs101 valueForKeyPath:@"teacher.name"]];
    [self assertTrue: _sawObservation message:"Never recieved an observation"];
}

- (void)testThreePartKey
{
    focus = [CarTester new];
    cs101 = [ClassTester new];
    bob = [PersonTester new];
        
    [cs101 setTeacher:bob];
    [bob setValue:focus forKey:"car"];

    [cs101 addObserver:self forKeyPath:@"teacher.car.model" options:nil context:"testThreePartKey"];

    [focus setValue:"ford focus" forKey:"model"];
    [self assertTrue: _sawObservation message:"Never recieved an observation"];
}

- (void)testThreePartKeyPart2
{
    focus = [CarTester new];
    cs101 = [ClassTester new];
    bob = [PersonTester new];
        
    [cs101 setTeacher:bob];
    [focus setValue:"2000" forKey:"year"];

    [cs101 addObserver:self forKeyPath:@"teacher.car.year" options:nil context:"testThreePartKeyPart2"];
    
    [bob setValue:focus forKey:"car"];

    [self assertTrue: _sawObservation message:"Never recieved an observation"];
}

- (void)testRemoveMultipartKey
{
    cs101 = [ClassTester new];
    bob = [PersonTester new];
    
    [cs101 setTeacher:bob];
    
    [cs101 addObserver:self forKeyPath:@"teacher.name" options:nil context:"testRemoveMultipartKey"];
    
    [cs101 removeObserver:self forKeyPath:@"teacher.name"];
    
    [bob setName:@"bob"];
    
    [self assertFalse: _sawObservation message:"Should not have recieved an observation"];
}

- (void)testRemoveThreePartKey
{
    focus = [CarTester new];
    cs101 = [ClassTester new];
    bob = [PersonTester new];
        
    [cs101 setTeacher:bob];
    [bob setValue:focus forKey:"car"];

    [cs101 addObserver:self forKeyPath:@"teacher.car.model" options:nil context:"testRemoveThreePartKey"];
    [cs101 removeObserver:self forKeyPath:@"teacher.car.model"];

    [focus setValue:"ford focus" forKey:"model"];

    [self assertFalse: _sawObservation message:"Should not have recieved an observation"];
}


- (void)testCrazyKeyPathChanges
{
    var a = [A new];
    
    [a setValue:[B new] forKeyPath:"b"];
    [a setValue:[C new] forKeyPath:"b.c"];
    [a setValue:[D new] forKeyPath:"b.c.d"];
    [a setValue:[E new] forKeyPath:"b.c.d.e"];
    [a setValue:[F new] forKeyPath:"b.c.d.e.f"];
    
    [a addObserver:self forKeyPath:"b.c.d.e.f" options:nil context:"testCrazyKeyPathChanges"];
    
    [a setValue:[D new] forKeyPath:"b.c.d"];
    
    [self assertTrue: _sawObservation message:"Never recieved an observation"];
}

- (void)testCrazyKeyPathChanges2
{
    var a = [A new];
    
    [a setValue:[B new] forKeyPath:"b"];
    [a setValue:[C new] forKeyPath:"b.c"];
    [a setValue:[D new] forKeyPath:"b.c.d"];
    [a setValue:[E new] forKeyPath:"b.c.d.e"];
    [a setValue:[F new] forKeyPath:"b.c.d.e.f"];
    
    [a addObserver:self forKeyPath:"b.c.d.e.f" options:nil context:"testCrazyKeyPathChanges2"];
    
    [a setValue:nil forKeyPath:"b.c"];
    
    [self assertTrue: _sawObservation message:"Never recieved an observation"];
}

- (void)testCrazyKeyPathChanges3
{
    var a = [A new];
    
    [a setValue:[B new] forKeyPath:"b"];
    [a setValue:[C new] forKeyPath:"b.c"];
    [a setValue:[D new] forKeyPath:"b.c.d"];
    [a setValue:[E new] forKeyPath:"b.c.d.e"];
    [a setValue:[F new] forKeyPath:"b.c.d.e.f"];
    
    [a addObserver:self forKeyPath:"b.c.d.e.f" options:nil context:"testCrazyKeyPathChanges3"];
    
    [a setValue:7 forKeyPath:"b.c.d.e.f"];
    
    [self assertTrue: _sawObservation message:"Never recieved an observation"];
}

- (void)testPerformance
{
    bob = [PersonTester new];
    
    [bob setValue:"initial bob" forKey:"name"];

    var startTime = new Date();
    
    for(var i=0; i<1000; i++)
        [bob setValue:i+"bob" forKey:"name"];
        
    var total = new Date() - startTime;

    [bob addObserver:[CPObject new] forKeyPath:"name" options:nil context:nil];

    startTime = new Date();
    
    for(var i=0; i<1000; i++)
        [bob setValue: i+"bob" forKey:"name"];
        
    var secondTotal = new Date() - startTime;

    [self assertTrue: (secondTotal < total*3) message: "Overheard of one observer exceeded 300%. first: "+total+" second: "+secondTotal+" %"+FLOOR(secondTotal/total*100)];
}

- (void)observeValueForKeyPath:(CPString)aKeyPath ofObject:(id)anObject change:(CPDictionary)changes context:(id)aContext
{
    var oldValue = [changes objectForKey:CPKeyValueChangeOldKey],
        newValue = [changes objectForKey:CPKeyValueChangeNewKey];

    switch (aContext)
    {
        case "testAddObserver": 
            [self assertTrue: newValue == "set_bob" message: "newValue should be: set_bob was: "+newValue];
            [self assertTrue: oldValue == [CPNull null] message: "oldValue should be CPNull was: "+oldValue];
            [self assertTrue: anObject == bob message: "anObject should be: "+[bob description]+", was: "+[anObject description]];
            break;
        case "testUnobservedKey": 
            [self assertFalse: YES message: "not observing this key, should never get here"];
            break;
        case "testAddTwoObservers":             
            [self assertTrue: newValue == "set_bob" message: "newValue should be: set_bob was: "+newValue];
            [self assertTrue: oldValue == [CPNull null] message: "oldValue should be CPNull was: "+oldValue];
            break;
            
        case "testDirectIVarObservation":
            [self assertTrue: newValue == "555" message: "newValue should be: 555 was: "+newValue];
            [self assertTrue: oldValue == [CPNull null] message: "oldValue should be CPNull was: "+oldValue];
            break;

        case "testRemoveObserver":
            [self assertTrue: NO message: "observer was removed, but notification was still received"];
            break;

        case "testRemoveOtherObserver":
            [self assertTrue: newValue == "set_bob" message: "newValue should be: set_bob was: "+newValue];
            [self assertTrue: oldValue == [CPNull null] message: "oldValue should be CPNull was: "+oldValue];
            break;

        case "testRemoveAllObservers":
            [self assertTrue: NO message: "all observers were removed, but notification was still received"];
            break;
            
        case "testPriorObservationOption":
            var prior = [changes objectForKey:CPKeyValueChangeNotificationIsPriorKey];
            
            if (!_sawPriorObservation)
            {
                [self assertTrue:prior message:"Have not been sent the prior notification, but it should have been sent"];
                [self assertTrue:oldValue == [CPNull null] message: "Shoudl be no initial value"];
                [self assertFalse:newValue message: "Should be no object for the new value key on the prior notification"];
                _sawPriorObservation = YES;
            }
            else
            {
                [self assertFalse: prior message: "there should be no value for the notification is prior key, that notification was already sent"];
                [self assertTrue: newValue == "set_bob" message: "newValue should be: set_bob was: "+newValue];
            }
            break;
            
        case "testInitialObservationOption":
            if (!_sawInitialObservation)
            {
                [self assertTrue: newValue == "paul" message:"Expected old value to be: paul was: "+oldValue];
                [self assertFalse: oldValue message:"Should be no value for new change key on initial observation"];
                _sawInitialObservation = YES;
            }
            else
                [self assertFalse:YES message:"Should never have received this notification"];

            break;
            
        case "testMultipartKey":
            [self assertTrue: aKeyPath == "teacher.name" message:"Keypath should be: teacher.name, was: "+aKeyPath];
            [self assertTrue: newValue == "set_bob" message:"New value should be: set_bob, was: "+newValue];
            [self assertTrue: anObject == cs101 message: "anObject should be: "+[cs101 description]+", was: "+[anObject description]];
            break;
            
        case "testRemoveMultipartKey":
            [self assertFalse:YES message:"Should never have received this notification"];
            break;

        case "testRemoveThreePartKey":
            [self assertFalse:YES message:"Should never have received this notification"];
            break;

        case "testThreePartKey":
            [self assertTrue: aKeyPath == "teacher.car.model" message:"Keypath should be: teacher.car.model, was: "+aKeyPath];
            [self assertTrue: newValue == "ford focus" message:"New value should be: ford focus, was: "+newValue];
            [self assertTrue: anObject == cs101 message: "anObject should be: "+[cs101 description]+", was: "+[anObject description]];
            break;

        case "testThreePartKeyPart2":
            [self assertTrue: aKeyPath == "teacher.car" message:"Keypath should be: teacher.car, was: "+aKeyPath];
            [self assertTrue: newValue.year == "2000" message:"New value should be a car with year: 2000, was: "+[newValue description]];
            [self assertTrue: anObject == cs101 message: "anObject should be: "+[cs101 description]+", was: "+[anObject description]];
            break;
            
        case "testCrazyKeyPathChanges":
            [self assertTrue: [anObject class] == A message:"Should be observing an A class, was: "+[anObject class]];
            [self assertTrue: [newValue class] == D message:"Changed class was a D class, got: "+[newValue class]];
            [self assertTrue: aKeyPath == "b.c.d" message:"Expected keyPath b.c.d, got: "+aKeyPath];
            break;

        case "testCrazyKeyPathChanges2":
            [self assertTrue: [anObject class] == A message:"Should be observing an A class, was: "+[anObject class]];
            [self assertTrue: newValue == [CPNull null] message:"Expected null, got: "+newValue];
            [self assertTrue: aKeyPath == "b.c" message:"Expected keyPath b.c, got: "+aKeyPath];
            break;

        case "testCrazyKeyPathChanges3":
            [self assertTrue: [anObject class] == A message:"Should be observing an A class, was: "+[anObject class]];
            [self assertTrue: newValue == 7 message:"Expected 7, got: "+newValue];
            [self assertTrue: aKeyPath == "b.c.d.e.f" message:"Expected keyPath b.c.d.e.f, got: "+aKeyPath];
            break;
            
        default:
            [self assertFalse:YES message:"unhandled observation, must be an error"];
            return;
    }

    _sawObservation = YES;
}

@end

@implementation CPObject (KVO)

- (void)observeValueForKeyPath:(CPString)aKeyPath ofObject:(id)anObject change:(CPDictionary)changes context:(id)aContext
{

}

@end

@implementation PersonTester : CPObject
{
    CPString    name;
    CPString    phoneNumber;
    CarTester   car;
}

- (void)setName:(CPString)aName
{
    name = "set_"+aName;
}

@end

@implementation ClassTester : CPObject
{
    PersonTester    teacher;
    CPArray         students;
}

- (void)setTeacher:(PersonTester)aPerson
{
    teacher = aPerson;
}

@end

@implementation CarTester : CPObject
{
    CPString    model;
    CPString    year;
}

- (void)setModel:(CPString)aModel
{
    model = aModel;
}

@end

@implementation A : CPObject
{
    id  b;
}
@end
@implementation B : CPObject
{
    id  c;
}
@end
@implementation C : CPObject
{
    id  d;
}
@end
@implementation D : CPObject
{
    id  e;
}
@end
@implementation E : CPObject
{
    id  f;
}
@end
@implementation F : CPObject
{
    id  g;
}
@end