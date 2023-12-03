


gPlayTable.CreatePlay{

firstState = "testWrilRoundBall",
["testWrilRoundBall"] = {
        switch = function()
                if bufcnt(player.infraredCount("a") > 1 , 5) then                                                
                        return "testWrilRoundBall-whirlRobot"                    
                end
        end,
        a = whtCommonTask.goCmuRush(ball.pos,dir.playerToBall,_, flag.allow_dss+flag.dribbling),
        match = "(a)"
},

["testWrilRoundBall-whirlRobot"] = {
        switch = function()             
                if bufcnt(player.infraredCount("a") < 1,5) then
                        return "testWrilRoundBall"
                -- 旋转完成后,停止 
                elseif math.abs(player.toTheirGoalDir("a")-player.dir("a")) < 0.01 then
                        return "testWrilRoundBall-stop"
                end 
        end,
        a = whtAttackTask.CSwhirlRobotToShoot("a"),
        match = "{a}"
},

["testWrilRoundBall-stop"] = {
        switch = function()
            debugEngine:gui_debug_x(CGeoPoint:new_local(param.pitchLength/2,0))
            debugEngine:gui_debug_msg(CGeoPoint:new_local(-1000,2500),"A的弧度与A指向球的弧度之间的偏差:"..tostring(player.dir("a")-dir.playerToBall("a")),1)
            debugEngine:gui_debug_msg(CGeoPoint:new_local(-1000,2000),"A的弧度与A指向目标点之间的偏差:"..tostring(player.dir("a")-player.toTheirGoalDir("a")),1)
            debugEngine:gui_debug_line(player.pos("a"),player.pos("a")+ Utils.Polar2Vector(2000,player.dir("a")),4);
            debugEngine:gui_debug_line(player.pos("a"),ball.pos(),5);
            debugEngine:gui_debug_line(player.pos("a"),CGeoPoint:new_local(param.pitchLength/2,0),6);  

        end,
        a = whtCommonTask.stop(),
        match = "{a}"
},

--结束



name = "test1-22",
applicable ={
	exp = "a",
	a = true
},
attribute = "attack",
timeout = 99999
}
