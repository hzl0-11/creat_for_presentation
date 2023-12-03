
--测试debug输出

gPlayTable.CreatePlay{

firstState = "test",

["test"] = {

        switch = function()
                debugEngine:gui_debug_x(CGeoPoint:new_local(-1000,2000))
                debugEngine:gui_debug_msg(CGeoPoint:new_local(-1000,2500),"坐标X:"..tostring(ball.posX()).."坐标Y:"..tostring(ball.posY()).."    是球的坐标",2)
                debugEngine:gui_debug_arc(CGeoPoint:new_local(0,0),1000,90,30,3)
                debugEngine:gui_debug_triangle(CGeoPoint:new_local(-1000,-1000),CGeoPoint:new_local(1000,1000),CGeoPoint:new_local(2000,-2000),3);
                debugEngine:gui_debug_robot(CGeoPoint:new_local(-1000,-1000), -math.pi/2);
                debugEngine:gui_debug_line(CGeoPoint:new_local(-1000,-2000),CGeoPoint:new_local(1000,1000),6);

        end,
        a = whtCommonTask.stop(),
        match = "{a}"
},

name = "test1-01",
applicable ={
	exp = "a",
	a = true
},
attribute = "attack",
timeout = 99999
}
