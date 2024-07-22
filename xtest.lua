local error, type, tostring, pairs = error, type, tostring, pairs
local xtest = {}

--- Converts a value to a string for printing.
--- Adds quotation marks around string values
---@param s any
---@return string
local function stringify(s)
  --TODO: Serialize tables to make them printable
  if type(s) == "string" then return '"' .. s .. '"' end
  return tostring(s)
end

local function fail(sMainMessage, sAssertionMessage, nLevel)
  --Level is set to three so the error points back to the user's test file
  error("assertion " .. (sAssertionMessage and (sAssertionMessage .. " ") or "") .. "failed" ..
    (sMainMessage and ":\n" .. sMainMessage or "!"),
    nLevel or 3)
end

local DEFAULT_TEST_SETTINGS = {
  continue = false,
  printLabel = true,
  printResults = true,
  printHeader = true
}

---Runs each test sequencially
---@param tests (function|string)[] the array of test functions and test labels
---@param testSettings? any
---@param printFn? fun(...:string)
---@return boolean success, string results
function xtest.run(tests, testSettings, printFn)
  if type(tests) ~= "table" then error("tests must be a table of functions and label strings") end

  local print = printFn or print

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
        label = label and (label .. '\n' .. test) or test
      end
    elseif type(test) == "function" then
      if testSettings.printLabel then
        testNumber = testNumber + 1
        print("Test #" .. testNumber .. " : " .. (label or "") .. "\n")
        label = nil
      end

      local ok, message = pcall(test)
      if ok then
        passed = passed + 1
        print"passed!\n"
      else
        failed = failed + 1
        print(message)
        if not testSettings.continue then break end
      end
    else
      error(
      "tests should only contain a string label or a function, but instead got " .. test .." of type".. type(test) .. " at index " .. i ..
      ".", 1)
    end
  end

  local results = ("Test results:\n\tpassed: %s\n\tfailed: %s\n\ttotal: %s"):format(passed, failed, passed + failed)
  if testSettings.printResults then
    print(results)
  end
  return failed == 0, results
end

-- Basic assertions

function xtest.assert(cond, message)
  if not cond then fail(message) end
  return cond
end

function xtest.assertNot(cond, message)
  if cond then fail(message) end
  return cond
end

-- Arithmetic assertions

function xtest.assertEq(left, right)
  if left ~= right then fail("left = " .. stringify(left) .. ",\nright = " .. stringify(right), "'left == right'") end
  return left, right
end

function xtest.assertNe(left, right)
  if left == right then fail("left = " .. stringify(left) .. ",\nright = " .. stringify(right), "'left ~= right'") end
  return left, right
end

function xtest.assertLt(left, right)
  if left >= right then fail("left = " .. tostring(left) .. ",\nright = " .. tostring(right), "'left < right'") end
  return left, right
end

function xtest.assertGt(left, right)
  if left <= right then fail("left = " .. tostring(left) .. ",\nright = " .. tostring(right), "'left > right'") end
  return left, right
end

function xtest.assertLe(left, right)
  if left > right then fail("left = " .. tostring(left) .. ",\nright = " .. tostring(right), "'left <= right'") end
  return left, right
end

function xtest.assertGe(left, right)
  if left < right then fail("left = " .. tostring(left) .. ",\nright = " .. tostring(right), "'left >= right'") end
  return left, right
end

-- Type assertions

function xtest.assertNil(value)
  if value ~= nil then fail("type(value) = ".. type(value), "'value == nil'") end
	return value
end

function xtest.assertNumber(value)
  if type(value) ~= "number" then fail("type(value) = ".. type(value), "'type(value) == number'") end
	return value
end

function xtest.assertInteger(value)
  if type(value) ~= "number" then fail("type(value) = ".. type(value), "'type(value) == number'") end
  if math.floor(value) ~= value then fail("value = ".. value, "'value is integer'") end
	return value
end

function xtest.assertString(value)
  if type(value) ~= "string" then fail("type(value) = ".. type(value), "'type(value) == string'") end
	return value
end

function xtest.assertBoolean(value)
  if type(value) ~= "boolean" then fail("type(value) = ".. type(value), "'type(value) == boolean'") end
	return value
end

function xtest.assertTrue(value)
  if value ~= true then fail("value = ".. value, "'value == true'") end
	return value
end

function xtest.assertFalse(value)
  if value ~= false then fail("value = ".. value, "'value == false'") end
	return value
end

function xtest.assertTable(value)
  if type(value) ~= "table" then fail("type(value) = ".. type(value), "'type(value) == table'") end
	return value
end

function xtest.assertFunction(value)
  if type(value) ~= "function" then fail("type(value) = ".. type(value), "'type(value) == function'") end
	return value
end

function xtest.assertThread(value)
  if type(value) ~= "thread" then fail("type(value) = ".. type(value), "'type(value) == thread'") end
	return value
end

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

return xtest
