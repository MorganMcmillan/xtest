local error, type, tostring, pairs = error, type, tostring, pairs
local xtest = {}

--- Converts a value to a string for printing.
--- Adds quotation marks around string values
---@param s any
---@return string
local function stringify(s)
  --TODO: Serialize tables to make them printable
  if type(s) == "string" then return ("%q"):format(s) end
  return tostring(s)
end

local function fail(sMainMessage, sAssertionMessage, nLevel)
  --Level is set to three so the error points back to the user's test file
  error("assertion " .. (sAssertionMessage and (sAssertionMessage .. " ") or "") .. "failed" ..
    (sMainMessage and ":\n" .. sMainMessage or "!"),
    nLevel or 3)
end

---@class (exact) TestSettings
---@field continue boolean whether or not the test should continue in the case that one fails
---@field printLabel boolean should each test print its label
---@field printResults boolean should results be printed

---@type TestSettings
local DEFAULT_TEST_SETTINGS = {
  continue = false,
  printLabel = true,
  printResults = true,
}

---Runs each test sequencially
---@param tests (function|string)[] the array of test functions and test labels
---@param testSettings? TestSettings
---@param printFn? fun(...:string)
---@return boolean success, table results
function xtest.run(tests, testSettings, printFn)
  if type(tests) ~= "table" then error("Tests must be a table of functions and label strings") end

  local print = printFn or print

  -- Load test settings
  if testSettings then
    for k, v in pairs(DEFAULT_TEST_SETTINGS) do
      if testSettings[k] == nil then
        testSettings[k] = v
      end
    end
  else
    testSettings = DEFAULT_TEST_SETTINGS
  end

  -- This is used instead of i so we only count the amount of functions that have been run
  local testNumber = 0
  local passed, failed = 0, 0
  local label = nil

  for i = 1, #tests do
    local test = tests[i]

    if type(test) == "string" then
      if testSettings.printLabel then
        -- Set the label of the current test
        -- Appending it as a new line if there was already one
        label = label and (label .. '\n' .. test) or test
      end

    elseif type(test) == "function" then
      testNumber = testNumber + 1
      if testSettings.printLabel then
        print("Test #" .. testNumber .. " : " .. (label or "") .. "\n")
        label = nil
      end

      local ok, message = pcall(test)
      if ok then
        passed = passed + 1
        if testSettings.printLabel then print"Passed!\n" end
      else
        failed = failed + 1
        if testSettings.printLabel then print"Failed!\n" end
        if testSettings.printLabel then print(message) end
        if not testSettings.continue then break end
      end
    else
      error(
      "Tests should only contain a string label or a function, but instead got " .. test .." of type".. type(test) .. " at index " .. i ..
      ".", 1)
    end
  end

  local results = { passed = passed, failed = failed, total = testNumber}
  if testSettings.printResults then
    print(("Test results:\n\tpassed: %s\n\tfailed: %s\n\ttotal: %s"):format(passed, failed, testNumber))
  end
  return failed == 0, results
end

-- Basic assertions

---Asserts the given condition is true, and fails with a message if it does not
---@param cond any
---@param message? string
---@return any cond
function xtest.assert(cond, message)
  message = message or "Condition is true"
  if not cond then fail(message) end
  return cond
end

---Asserts the given condition is false, and fails with a message if it does not
---@param cond any
---@param message? string
---@return any cond
function xtest.assertNot(cond, message)
  message = message or "Condition is not true"
  if cond then fail(message) end
  return cond
end

-- Arithmetic assertions

---Asserts that `left` expression is equal to `right` expression
---@param left number
---@param right number
---@return number left
---@return number right
function xtest.assertEq(left, right)
  if left ~= right then fail("left = " .. stringify(left) .. ",\nright = " .. stringify(right), "'left == right'") end
  return left, right
end

---Asserts that `left` expression is not equal to `right` expression
---@param left number
---@param right number
---@return number left
---@return number right
function xtest.assertNe(left, right)
  if left == right then fail("left = " .. stringify(left) .. ",\nright = " .. stringify(right), "'left ~= right'") end
  return left, right
end

---Asserts that `left` expression is less than `right` expression
---@param left number
---@param right number
---@return number left
---@return number right
function xtest.assertLt(left, right)
  if left >= right then fail("left = " .. tostring(left) .. ",\nright = " .. tostring(right), "'left < right'") end
  return left, right
end

---Asserts that `left` expression is greater than `right` expression
---@param left number
---@param right number
---@return number left
---@return number right
function xtest.assertGt(left, right)
  if left <= right then fail("left = " .. tostring(left) .. ",\nright = " .. tostring(right), "'left > right'") end
  return left, right
end

---Asserts that `left` expression is less than or equal to `right` expression
---@param left number
---@param right number
---@return number left
---@return number right
function xtest.assertLe(left, right)
  if left > right then fail("left = " .. tostring(left) .. ",\nright = " .. tostring(right), "'left <= right'") end
  return left, right
end

---Asserts that `left` expression is greater than or equal to `right` expression
---@param left number
---@param right number
---@return number left
---@return number right
function xtest.assertGe(left, right)
  if left < right then fail("left = " .. tostring(left) .. ",\nright = " .. tostring(right), "'left >= right'") end
  return left, right
end

-- Type assertions

---Asserts that `value` is of type `nil`
---@param value any
---@return any value
function xtest.assertNil(value)
  if value ~= nil then fail("type(value) = ".. type(value), "'value == nil'") end
	return value
end

---Asserts that `value` is of type `number`
---@param value any
---@return any value
function xtest.assertNumber(value)
  if type(value) ~= "number" then fail("type(value) = ".. type(value), "'type(value) == number'") end
	return value
end

---Asserts that `value` is of type `number` and is an integer
---@param value any
---@return any value
function xtest.assertInteger(value)
  if type(value) ~= "number" then fail("type(value) = ".. type(value), "'type(value) == number'") end
  if math.floor(value) ~= value then fail("value = ".. value, "'value is integer'") end
	return value
end

---Asserts that `value` is of type `string`
---@param value any
---@return any value
function xtest.assertString(value)
  if type(value) ~= "string" then fail("type(value) = ".. type(value), "'type(value) == string'") end
	return value
end

---Asserts that `value` is of type `nil`
---@param value any
---@return any value
function xtest.assertBoolean(value)
  if type(value) ~= "boolean" then fail("type(value) = ".. type(value), "'type(value) == boolean'") end
	return value
end

---Asserts that `value` is of type `nil`
---@param value any
---@return any value
function xtest.assertTrue(value)
  if value ~= true then fail("value = ".. value, "'value == true'") end
	return value
end

---Asserts that `value` is of type `nil`
---@param value any
---@return any value
function xtest.assertFalse(value)
  if value ~= false then fail("value = ".. value, "'value == false'") end
	return value
end

---Asserts that `value` is of type `nil`
---@param value any
---@return any value
function xtest.assertTable(value)
  if type(value) ~= "table" then fail("type(value) = ".. type(value), "'type(value) == table'") end
	return value
end

---Asserts that `value` is of type `nil`
---@param value any
---@return any value
function xtest.assertFunction(value)
  if type(value) ~= "function" then fail("type(value) = ".. type(value), "'type(value) == function'") end
	return value
end

---Asserts that `value` is of type `nil`
---@param value any
---@return any value
function xtest.assertThread(value)
  if type(value) ~= "thread" then fail("type(value) = ".. type(value), "'type(value) == thread'") end
	return value
end

---Asserts that `value` is of type `nil`
---@param value any
---@return any value
function xtest.assertUserdata(value)
  if type(value) ~= "userdata" then fail("type(value) = ".. type(value), "'type(value) == userdata'") end
	return value
end

---Asserts that a value is of a given type
---@param value any
---@param sType "nil" | "number" | "string" | "boolean" | "table" | "function" | "thread" | "userdata"
---@return any value
function xtest.assertType(value, sType)
  local ty = type(value)
  if ty ~= sType then fail("value = " .. stringify(value) .. "\ntype = " .. ty, "'type(v) == " .. sType .. "'") end
  return value
end

---Asserts that a value is not of a given type
---@param value any
---@param sType "nil" | "number" | "string" | "boolean" | "table" | "function" | "thread" | "userdata"
---@return any value
function xtest.assertNotType(value, sType)
  if type(value) == sType then fail("value = " .. stringify(value) .. "\ntype = " .. sType, "'type(v) ~= " .. sType .. "'") end
  return value
end

-- Error checking assertions

---Asserts that a function does not throw an error when called
function xtest.assertOk(fun, ...)
  local result = {pcall(fun, ...)}
  if not result[1] then fail(result[2], "'function does not throw error'") end
  return table.unpack(result,2)
end

---Asserts that a function trows any error when called
function xtest.assertError(fun, ...)
  local result = {pcall(fun, ...)}
  if result[1] then fail(result[2], "'function throws error'") end
  return table.unpack(result,2)
end

return xtest
