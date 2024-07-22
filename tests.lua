-- This file is not to be confused with xtest.lua

local xtest = require("xtest")
-- shortened alias of xtest for convienience
local x = xtest

-- The following tests should all run successfully
local success, result = xtest.run({
  "xtest.assert",
  function ()
    x.assert(true,"always true")
    x.assertNot(false)
  end,
  "xtest.assertType",
  function ()
    x.assertType(nil,"nil")
    x.assertType(1,"number")
    x.assertType("I am a string","string")
    x.assertType(true,"boolean")
    x.assertType({},"table")
    x.assertType(function()end,"function")
    x.assertType(coroutine.create(function()end),"thread")
    --TODO: add assert for userdata
  end,
  "Arithmetic assertions",
  function ()
    x.assertEq(10,10)
    x.assertNe(10,20)
    x.assertGt(20,10)
    x.assertGe(20,15)
    x.assertGe(20,20)
    x.assertLt(10,20)
    x.assertLe(15,20)
    x.assertLe(20,20)
  end,
  "Type assertions",
  function ()
    x.assertNil(nil)
    x.assertNumber(10)
    x.assertNumber(0.5)
    x.assertInteger(10)
    x.assertString"I am a string"
    x.assertBoolean(true)
    x.assertBoolean(false)
    x.assertTrue(true)
    x.assertFalse(false)
    x.assertTable{}
    x.assertFunction(function()end)
    x.assertThread(coroutine.create(function()end))
    --TODO: add assert for userdata
  end
},{continue = true})
