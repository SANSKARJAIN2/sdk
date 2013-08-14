// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:expect/expect.dart';
import
    '../../../sdk/lib/_internal/compiler/implementation/types/types.dart'
    show TypeMask;

import 'compiler_helper.dart';
import 'parser_helper.dart';

const String TEST = """
returnNum1(a) {
  if (a) return 1;
  else return 2.0;
}

returnNum2(a) {
  if (a) return 1.0;
  else return 2;
}

returnInt1(a) {
  if (a) return 1;
  else return 2;
}

returnDouble(a) {
  if (a) return 1.0;
  else return 2.0;
}

returnGiveUp(a) {
  if (a) return 1;
  else return 'foo';
}

returnInt2() {
  var a = 42;
  return a++;
}

returnInt5() {
  var a = 42;
  return ++a;
}

returnInt6() {
  var a = 42;
  a++;
  return a;
}

returnIntOrNull(a) {
  if (a) return 42;
}

returnInt3(a) {
  if (a) return 42;
  throw 42;
}

returnInt4() {
  return (42);
}

returnInt7() {
  return 42.abs();
}

returnInt8() {
  return 42.remainder(54);
}

returnDynamic1() {
  // Ensure that we don't intrisify a wrong call to [int.remainder].
  return 42.remainder();
}

returnDynamic2() {
  // Ensure that we don't intrisify a wrong call to [int.abs].
  return 42.abs(42);
}

testIsCheck1(a) {
  if (a is int) {
    return a;
  } else {
    return 42;
  }
}

testIsCheck2(a) {
  if (a is !int) {
    return 0;
  } else {
    return a;
  }
}

testIsCheck3(a) {
  if (a is !int) {
    print('hello');
  } else {
    return a;
  }
}

testIsCheck4(a) {
  if (a is int) {
    return a;
  } else {
    return 42;
  }
}

testIsCheck5(a) {
  if (a is !int) {
    return 42;
  } else {
    return a;
  }
}

testIsCheck6(a) {
  if (a is !int) {
    return a;
  } else {
    return 42;
  }
}

testIsCheck7(a) {
  if (a == 'foo' && a is int) {
    return a;
  } else {
    return 42;
  }
}

testIsCheck8(a) {
  if (a == 'foo' || a is int) {
    return a;
  } else {
    return 42;
  }
}

testIsCheck9(a) {
  return a is int ? a : 42;
}

testIsCheck10(a) {
  return a is !int ? a : 42;
}

testIsCheck11(a) {
  return a is !int ? 42 : a;
}

testIsCheck12(a) {
  return a is int ? 42 : a;
}

testIsCheck13(a) {
  while (a is int) {
    return a;
  }
  return 42;
}

testIsCheck14(a) {
  while (a is !int) {
    return 42;
  }
  return a;
}

testIsCheck15(a) {
  var c = 42;
  do {
    if (a) return c;
    c = topLevelGetter();
  } while (c is int);
  return 42;
}

testIsCheck16(a) {
  var c = 42;
  do {
    if (a) return c;
    c = topLevelGetter();
  } while (c is !int);
  return 42;
}

testIsCheck17(a) {
  var c = 42;
  for (; c is int;) {
    if (a) return c;
    c = topLevelGetter();
  }
  return 42;
}

testIsCheck18(a) {
  var c = 42;
  for (; c is int;) {
    if (a) return c;
    c = topLevelGetter();
  }
  return c;
}

testIsCheck19(a) {
  var c = 42;
  for (; c is !int;) {
    if (a) return c;
    c = topLevelGetter();
  }
  return 42;
}

testIsCheck20() {
  var c = topLevelGetter();
  if (c != null && c is! bool && c is! int) {
    return 42;
  } else if (c is String) {
    return c;
  } else {
    return 68;
  }
}

returnAsString() {
  return topLevelGetter() as String;
}

returnIntAsNum() {
  return 0 as num;
}

typedef int Foo();

returnAsTypedef() {
  return topLevelGetter() as Foo;
}

testDeadCode() {
  return 42;
  return 'foo';
}

testLabeledIf(a) {
  var c;
  L1: if (a > 1) {
    if (a == 2) {
      break L1;
    }
    c = 42;
  } else {
    c = 38;
  }
  return c;
}

testSwitch1() {
  var a = null;
  switch (topLevelGetter) {
    case 100: a = 42.5; break;
    case 200: a = 42; break;
  }
  return a;
}

testSwitch2() {
  var a = null;
  switch (topLevelGetter) {
    case 100: a = 42; break;
    case 200: a = 42; break;
    default:
      a = 43;
  }
  return a;
}

testSwitch3() {
  var a = 42;
  var b;
  switch (topLevelGetter) {
    L1: case 1: b = a + 42; break;
    case 2: a = 'foo'; continue L1;
  }
  return b;
}

testSwitch4() {
  switch (topLevelGetter) {
    case 1: break;
    default: break;
  }
  return 42;
}

testSwitch5() {
  switch (topLevelGetter) {
    case 1: return 1;
    default: return 2;
  }
}

testContinue1() {
  var a = 42;
  var b;
  while (true) {
    b = a + 54;
    if (b == 42) continue;
    a = 'foo';
  }
  return b;
}

testBreak1() {
  var a = 42;
  var b;
  while (true) {
    b = a + 54;
    if (b == 42) break;
    b = 'foo';
  }
  return b;
}

testContinue2() {
  var a = 42;
  var b;
  while (true) {
    b = a + 54;
    if (b == 42) {
      b = 'foo';
      continue;
    }
  }
  return b;
}

testBreak2() {
  var a = 42;
  var b;
  while (true) {
    b = a + 54;
    if (b == 42) {
      a = 'foo';
      break;
    }
  }
  return b;
}

testReturnElementOfConstList1() {
  return const [42][0];
}

testReturnElementOfConstList2() {
  return topLevelConstList[0];
}

testReturnItselfOrInt(a) {
  if (a) return 42;
  return testReturnItselfOrInt(a);
}

testDoWhile1() {
  var a = 42;
  do {
    a = 'foo';
  } while (true);
  return a;
}

testDoWhile2() {
  var a = 42;
  do {
    a = 'foo';
    return;
  } while (true);
  return a;
}

testDoWhile3() {
  var a = 42;
  do {
    a = 'foo';
    if (true) continue;
    return 42;
  } while (true);
  return a;
}

testDoWhile4() {
  var a = 'foo';
  do {
    a = 54;
    if (true) break;
    return 3.5;
  } while (true);
  return a;
}

testReturnInvokeDynamicGetter() => new A().myFactory();

var topLevelConstList = const [42];

get topLevelGetter => 42;
returnDynamic() => topLevelGetter(42);
returnTopLevelGetter() => topLevelGetter;

class A {
  factory A() = A.generative;
  A.generative();
  operator==(other) => 42;

  get myField => 42;
  set myField(a) {}
  returnInt1() => ++myField;
  returnInt2() => ++this.myField;
  returnInt3() => this.myField += 42;
  returnInt4() => myField += 42;
  operator[](index) => 42;
  operator[]= (index, value) {}
  returnInt5() => ++this[0];
  returnInt6() => this[0] += 1;

  get myFactory => () => 42;
}

class B extends A {
  B() : super.generative();
  returnInt1() => ++new A().myField;
  returnInt2() => new A().myField += 4;
  returnInt3() => ++new A()[0];
  returnInt4() => new A()[0] += 42;
  returnInt5() => ++super.myField;
  returnInt6() => super.myField += 4;
  returnInt7() => ++super[0];
  returnInt8() => super[0] += 54;
  returnInt9() => super.myField;
}

testCascade1() {
  return [1, 2, 3]..add(4)..add(5);
}

testCascade2() {
  return new CascadeHelper()
      ..a = "hello"
      ..b = 42
      ..i += 1;
}

class CascadeHelper {
  var a, b;
  var i = 0;
}

main() {
  // Ensure a function class is being instantiated.
  () => 42;
  returnNum1(true);
  returnNum2(true);
  returnInt1(true);
  returnInt2(true);
  returnInt3(true);
  returnInt4();
  returnDouble(true);
  returnGiveUp(true);
  returnInt5();
  returnInt6();
  returnInt7();
  returnInt8();
  returnIntOrNull(true);
  returnDynamic();
  returnDynamic1();
  returnDynamic2();
  testIsCheck1(topLevelGetter());
  testIsCheck2(topLevelGetter());
  testIsCheck3(topLevelGetter());
  testIsCheck4(topLevelGetter());
  testIsCheck5(topLevelGetter());
  testIsCheck6(topLevelGetter());
  testIsCheck7(topLevelGetter());
  testIsCheck8(topLevelGetter());
  testIsCheck9(topLevelGetter());
  testIsCheck10(topLevelGetter());
  testIsCheck11(topLevelGetter());
  testIsCheck12(topLevelGetter());
  testIsCheck13(topLevelGetter());
  testIsCheck14(topLevelGetter());
  testIsCheck15(topLevelGetter());
  testIsCheck16(topLevelGetter());
  testIsCheck17(topLevelGetter());
  testIsCheck18(topLevelGetter());
  testIsCheck19(topLevelGetter());
  testIsCheck20();
  returnAsString();
  returnIntAsNum();
  returnAsTypedef();
  returnTopLevelGetter();
  testDeadCode();
  testLabeledIf();
  testSwitch1();
  testSwitch2();
  testSwitch3();
  testSwitch4();
  testSwitch5();
  testContinue1();
  testBreak1();
  testContinue2();
  testBreak2();
  testDoWhile1();
  testDoWhile2();
  testDoWhile3();
  testDoWhile4();
  new A() == null;
  new A()..returnInt1()
         ..returnInt2()
         ..returnInt3()
         ..returnInt4()
         ..returnInt5()
         ..returnInt6();

  new B()..returnInt1()
         ..returnInt2()
         ..returnInt3()
         ..returnInt4()
         ..returnInt5()
         ..returnInt6()
         ..returnInt7()
         ..returnInt8()
         ..returnInt9();
  testReturnElementOfConstList1();
  testReturnElementOfConstList2();
  testReturnItselfOrInt(topLevelGetter());
  testReturnInvokeDynamicGetter();
  testCascade1();
  testCascade2();
}
""";

void main() {
  Uri uri = new Uri(scheme: 'source');
  var compiler = compilerFor(TEST, uri);
  compiler.runCompiler(uri);
  var typesTask = compiler.typesTask;
  var typesInferrer = typesTask.typesInferrer;

  checkReturn(String name, type) {
    var element = findElement(compiler, name);
    Expect.equals(
        type,
        typesInferrer.getReturnTypeOfElement(element).simplify(compiler),
        name);
  }
  var interceptorType =
      findTypeMask(compiler, 'Interceptor', 'nonNullSubclass');

  checkReturn('returnNum1', typesTask.numType);
  checkReturn('returnNum2', typesTask.numType);
  checkReturn('returnInt1', typesTask.intType);
  checkReturn('returnInt2', typesTask.intType);
  checkReturn('returnDouble', typesTask.doubleType);
  checkReturn('returnGiveUp', interceptorType);
  checkReturn('returnInt5', typesTask.intType);
  checkReturn('returnInt6', typesTask.intType);
  checkReturn('returnIntOrNull', typesTask.intType.nullable());
  checkReturn('returnInt3', typesTask.intType);
  checkReturn('returnDynamic', typesTask.dynamicType);
  checkReturn('returnInt4', typesTask.intType);
  checkReturn('returnInt7', typesTask.intType);
  checkReturn('returnInt8', typesTask.intType);
  checkReturn('returnDynamic1', typesTask.dynamicType);
  checkReturn('returnDynamic2', typesTask.dynamicType);
  TypeMask intType = new TypeMask.nonNullSubtype(compiler.intClass.rawType);
  checkReturn('testIsCheck1', intType);
  checkReturn('testIsCheck2', intType);
  checkReturn('testIsCheck3', intType.nullable());
  checkReturn('testIsCheck4', intType);
  checkReturn('testIsCheck5', intType);
  checkReturn('testIsCheck6', typesTask.dynamicType);
  checkReturn('testIsCheck7', intType);
  checkReturn('testIsCheck8', typesTask.dynamicType);
  checkReturn('testIsCheck9', intType);
  checkReturn('testIsCheck10', typesTask.dynamicType);
  checkReturn('testIsCheck11', intType);
  checkReturn('testIsCheck12', typesTask.dynamicType);
  checkReturn('testIsCheck13', intType);
  checkReturn('testIsCheck14', typesTask.dynamicType);
  checkReturn('testIsCheck15', intType);
  checkReturn('testIsCheck16', typesTask.dynamicType);
  checkReturn('testIsCheck17', intType);
  checkReturn('testIsCheck18', typesTask.dynamicType);
  checkReturn('testIsCheck19', typesTask.dynamicType);
  checkReturn('testIsCheck20', typesTask.dynamicType.nonNullable());
  checkReturn('returnAsString',
      new TypeMask.subtype(compiler.stringClass.computeType(compiler)));
  checkReturn('returnIntAsNum', typesTask.intType);
  checkReturn('returnAsTypedef', typesTask.functionType.nullable());
  checkReturn('returnTopLevelGetter', typesTask.intType);
  checkReturn('testDeadCode', typesTask.intType);
  checkReturn('testLabeledIf', typesTask.intType.nullable());
  checkReturn('testSwitch1', typesTask.intType
      .union(typesTask.doubleType, compiler).nullable().simplify(compiler));
  checkReturn('testSwitch2', typesTask.intType);
  checkReturn('testSwitch3', interceptorType.nullable());
  checkReturn('testSwitch4', typesTask.intType);
  checkReturn('testSwitch5', typesTask.intType);
  checkReturn('testContinue1', interceptorType.nullable());
  checkReturn('testBreak1', interceptorType.nullable());
  checkReturn('testContinue2', interceptorType.nullable());
  checkReturn('testBreak2', typesTask.intType.nullable());
  checkReturn('testReturnElementOfConstList1', typesTask.intType);
  checkReturn('testReturnElementOfConstList2', typesTask.intType);
  checkReturn('testReturnItselfOrInt', typesTask.intType);
  checkReturn('testReturnInvokeDynamicGetter', typesTask.dynamicType);

  checkReturn('testDoWhile1', typesTask.stringType);
  checkReturn('testDoWhile2', typesTask.nullType);
  checkReturn('testDoWhile3', interceptorType);
  checkReturn('testDoWhile4', typesTask.numType);

  checkReturnInClass(String className, String methodName, type) {
    var cls = findElement(compiler, className);
    var element = cls.lookupLocalMember(buildSourceString(methodName));
    Expect.equals(type,
        typesInferrer.getReturnTypeOfElement(element).simplify(compiler));
  }

  checkReturnInClass('A', 'returnInt1', typesTask.intType);
  checkReturnInClass('A', 'returnInt2', typesTask.intType);
  checkReturnInClass('A', 'returnInt3', typesTask.intType);
  checkReturnInClass('A', 'returnInt4', typesTask.intType);
  checkReturnInClass('A', 'returnInt5', typesTask.intType);
  checkReturnInClass('A', 'returnInt6', typesTask.intType);
  checkReturnInClass('A', '==', interceptorType);

  checkReturnInClass('B', 'returnInt1', typesTask.intType);
  checkReturnInClass('B', 'returnInt2', typesTask.intType);
  checkReturnInClass('B', 'returnInt3', typesTask.intType);
  checkReturnInClass('B', 'returnInt4', typesTask.intType);
  checkReturnInClass('B', 'returnInt5', typesTask.intType);
  checkReturnInClass('B', 'returnInt6', typesTask.intType);
  checkReturnInClass('B', 'returnInt7', typesTask.intType);
  checkReturnInClass('B', 'returnInt8', typesTask.intType);
  checkReturnInClass('B', 'returnInt9', typesTask.intType);

  checkFactoryConstructor(String className, String factoryName) {
    var cls = findElement(compiler, className);
    var element = cls.localLookup(buildSourceString(factoryName));
    Expect.equals(new TypeMask.nonNullExact(cls.rawType),
                  typesInferrer.getReturnTypeOfElement(element));
  }
  checkFactoryConstructor('A', '');

  checkReturn('testCascade1', typesTask.growableListType);
  checkReturn('testCascade2', new TypeMask.nonNullExact(
      typesTask.rawTypeOf(findElement(compiler, 'CascadeHelper'))));
}
