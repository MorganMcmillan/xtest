-- This file is not to be confused with xtest.lua

local xtest = require("xtest")
-- shortened alias of xtest for convienience
local x = xtest

-- The following tests should all run successfully
local success, result = xtest.run({
  "xtest.assert",
  function()
    x.assert(true, "always true")
    x.assertNot(false, "always false")
  end,
  "Table eqality assertions",
  function()
    x.assertShallowEq({ 1, 2, 3 }, { 1, 2, 3 })
    -- Key order does not matter
    x.assertShallowEq({ a = 1, b = 2, c = 3 }, { c = 3, b = 2, a = 1 })
    x.assertShallowNe({ 1, 2, 3 }, { 1, 2, 4 })
    x.assertDeepEq({ 1, { 2, 3, 4 }, 5 }, { 1, { 2, 3, 4 }, 5 })
    x.assertDeepEq({ { a = 1, b = 2, c = 3 } }, { { c = 3, b = 2, a = 1 } })
    x.assertDeepNe({ 1, { 2, 69, 4 }, 5 }, { 1, { 2, 420, 4 }, 5 })
  end,
  "xtest.assertType",
  function()
    x.assertType(nil, "nil")
    x.assertType(1, "number")
    x.assertType("I am a string", "string")
    x.assertType(true, "boolean")
    x.assertType({}, "table")
    x.assertType(function() end, "function")
    x.assertType(coroutine.create(function() end), "thread")
    x.assertType(io.stdout, "userdata")
  end,
  "Arithmetic assertions",
  function()
    x.assertEq(10, 10)
    x.assertNe(10, 20)
    x.assertGt(20, 10)
    x.assertGe(20, 15)
    x.assertGe(20, 20)
    x.assertLt(10, 20)
    x.assertLe(15, 20)
    x.assertLe(20, 20)
  end,
  "Type assertions",
  function()
    x.assertNil(nil)
    x.assertNumber(10)
    x.assertNumber(0.5)
    x.assertInteger(10)
    x.assertString "I am a string"
    x.assertBoolean(true)
    x.assertBoolean(false)
    x.assertTrue(true)
    x.assertFalse(false)
    x.assertTable {}
    x.assertFunction(function() end)
    x.assertThread(coroutine.create(function() end))
    x.assertUserdata(io.stdout)
  end,
  "Error assertions",
  function()
    x.assertOk(function() end)
    x.assertError(function() error("error") end)
    -- Assert that all assert functions work in case of failure
    print "Note that none of the following failure messages are actuall failures of the test:"
    print(x.assertError(x.assert, false, "always false"))
    print(x.assertError(x.assert, false)) -- No message
    print(x.assertError(x.assertNot, true, "always true"))
    print(x.assertError(x.assertNot, true)) -- No message
    -- Arithmetic
    print(x.assertError(x.assertLt, 20, 10))
    print(x.assertError(x.assertGt, 5, 100))
    print(x.assertError(x.assertLe, 420, 69))
    print(x.assertError(x.assertGe, 1, 50))
    -- Type
    print(x.assertError(x.assertType, 10, "string"))
    print(x.assertError(x.assertNotType, "I am not a string", "string"))
    print(x.assertError(x.assertNil, not not nil))
    print(x.assertError(x.assertNumber, "ten"))
    print(x.assertError(x.assertInteger, 3.14))
    print(x.assertError(x.assertString, 0xb00b5))
    print(x.assertError(x.assertBoolean, "I am totally a true!"))
    print(x.assertError(x.assertTrue, false))
    print(x.assertError(x.assertFalse, true))
    print(x.assertError(x.assertTable, "I am not a table!"))
    print(x.assertError(x.assertFunction, "Yes I am function, y u no run?"))
    print(x.assertError(x.assertThread, "A string is a type of thread, no?"))
    print(x.assertError(x.assertUserdata, "struct Foo;"))
  end
}, { continue = true })
