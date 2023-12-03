local movePoint = function(dist)
        return function()
                return CGeoPoint:new_local(ball.posX(),ball.posY()+dist)
        end
end 



gPlayTable.CreatePlay{

firstState = "testRoundBall",
--绕球旋转技能速度变速控制测试
["testRoundBall"] = {
        switch = function()
                if bufcnt(player.toTargetDist("a") < 10 and player.toTargetDist("b") < 10, 3) then                                             
                        return "testRoundBall-begin"
                end
        end,
        a = whtCommonTask.goCmuRush(movePoint(1000),dir.playerToBall,_, flag.allow_dss+ flag.dodge_ball),
        b = whtCommonTask.goCmuRush(movePoint(200),dir.playerToBall,_, flag.allow_dss+ flag.dodge_ball),
        match = "(a)(b)"
},

["testRoundBall-begin"] = {
        switch = function() 
                if bufcnt(player.toTargetDist("a") < 10 and player.toTargetDist("b") < 10, 3) then                                             
                        return "testRoundBall-stop"
                end
        end,
        a = whtAttackTask.CSroundBallToShoot("a",1000),
        b = whtAttackTask.CSroundBallToShoot("b",200),
        match = "{ab}"
},

["testRoundBall-stop"] = {
        switch = function()
                debugEngine:gui_debug_x(CGeoPoint:new_local(param.pitchLength/2,0))
                debugEngine:gui_debug_arc(ball.pos(),1000,0,360,3)
                debugEngine:gui_debug_arc(ball.pos(),200,0,360,4)
                debugEngine:gui_debug_msg(CGeoPoint:new_local(-1000,2500),"A的弧度与A指向球的弧度之间的偏差:"..tostring(player.dir("a")-dir.playerToBall("a")),1)
                debugEngine:gui_debug_msg(CGeoPoint:new_local(-1000,2000),"A的弧度与A指向目标点之间的偏差:"..tostring(player.dir("a")-player.toTheirGoalDir("a")),1)
                debugEngine:gui_debug_line(player.pos("a"),player.pos("a")+ Utils.Polar2Vector(2000,player.dir("a")),4);
                debugEngine:gui_debug_line(player.pos("a"),ball.pos(),5);
                debugEngine:gui_debug_line(player.pos("a"),CGeoPoint:new_local(param.pitchLength/2,0),6);                
                debugEngine:gui_debug_msg(CGeoPoint:new_local(-1000,-2000),"B的弧度与B指向球的弧度之间的偏差:"..tostring(player.dir("b")-dir.playerToBall("b")),1)
                debugEngine:gui_debug_msg(CGeoPoint:new_local(-1000,-2500),"B的弧度与B指向目标点之间的偏差:"..tostring(player.dir("b")-player.toTheirGoalDir("b")),1)
                debugEngine:gui_debug_line(player.pos("b"),player.pos("b")+ Utils.Polar2Vector(1000,player.dir("b")),4);
                debugEngine:gui_debug_line(player.pos("b"),ball.pos(),5);   
                debugEngine:gui_debug_line(player.pos("b"),CGeoPoint:new_local(param.pitchLength/2,0),6); 
        end,
        a = whtCommonTask.stop(),
        b = whtCommonTask.stop(),
        match = "{ab}"
},


--结束


name = "test1-20",
applicable ={
	exp = "a",
	a = true
},
attribute = "attack",
timeout = 99999
}
