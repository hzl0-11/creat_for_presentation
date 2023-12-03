

-- 需测试挑射力度和加速度

gPlayTable.CreatePlay{

firstState = "testGoalie",

["testGoalie"] = {
        switch = function()
        end,
        Goalie = whtDefTask.luaGoalie_1(),
        match = ""
},


name = "wht_def_2_1-2",
applicable ={
	exp = "a",
	a = true
},
attribute = "attack",
timeout = 99999
}
