local count = 0
local count1 = 0
function countZS()
    -- local count = 0
    return function()
        count = count +1
        return count
    end 
end


function countZS1()
    return function()
        count1 = count1 +1
        return count1
    end 
end


local c = countZS()

local c1 = countZS1()


gPlayTable.CreatePlay{

firstState = "test1",

["test"] = {

        switch = function()
                debugEngine:gui_debug_x(CGeoPoint:new_local(-2000,1000),1);
                debugEngine:gui_debug_msg(CGeoPoint:new_local(-2000,2000),"      当前帧数:" .. tostring(c()),1)
                if bufcnt(true,60,30) then
                        count = 0
                        return "test1"
                end
        end,

        a = whtCommonTask.stop(),
        match = "{a}"
},


["test1"] = {

        switch = function()
                debugEngine:gui_debug_x(CGeoPoint:new_local(2000,1000),3);
                debugEngine:gui_debug_msg(CGeoPoint:new_local(2000,2000),"      当前帧数:" .. tostring(c1()),3)
                if bufcnt(true,120) then
                        count1 = 0
                        return "test"
                end
        end,

        a = whtCommonTask.stop(),
        match = "{a}"
},




name = "test1-06",
applicable ={
	exp = "a",
	a = true
},
attribute = "attack",
timeout = 99999
}
