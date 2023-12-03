

local movePoint = function()
                return CGeoPoint:new_local(2000,-1000)
end 



gPlayTable.CreatePlay{

firstState = "test",

switch = function()
        debugEngine:gui_debug_x(movePoint(),1);
end,
["test"] = {

        switch = function()
                debugEngine:gui_debug_x(CGeoPoint:new_local(-2000,1000),2);
                if bufcnt(true,10) then
                        return "test1"
                end
        end,

        a = whtCommonTask.stop(),
        match = "{a}"
},

["test1"] = {

        switch = function()
                debugEngine:gui_debug_x(CGeoPoint:new_local(-2000,-1000),1);
                if bufcnt(true,10) then
                        return "test"
                end 
        end,
        a = whtCommonTask.stop(),
        match = "{a}"
},

name = "test1-05",
applicable ={
	exp = "a",
	a = true
},
attribute = "attack",
timeout = 99999
}
