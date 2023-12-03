--避球又避车
local DSS_FLAG_all = flag.allow_dss + flag.dodge_ball  

--只避车
local DSS_FLAG_onlyRobot = flag.allow_dss




--测试判断距离精度和碰球的帧数

gPlayTable.CreatePlay{
firstState = "prepare",

-- 向球附近的某点跑,位置为想射门的点与球的连线的延长线上,机器人的弧度指向球
["prepare"] = {
    switch = function() 
            if bufcnt(player.toTargetDist("a") < 20  ,10) then                         
                return "prepareShoot"
            end
    end,

    a = whtCommonTask.goCmuRush(whtAttackFunction.prepareShootPos(250,100,150), dir.playerToBall,_, DSS_FLAG_all),
	match = "{a}"
},

["prepareShoot"] = {
    switch = function() 
                if bufcnt(player.infraredCount("a") > 1 ,1) then                                             
                	return "shoot"
                end
    end,
    a = whtCommonTask.goCmuRush(ball.pos, dir.playerToBall,_, DSS_FLAG_onlyRobot),
	match = "{a}"
},

["shoot"] = {
    switch = function()
    	if player.kickBall("a") then
            return "prepare"
        end 
    end,
	a = whtAttackTask.directShoot(),
	match = "{a}"
},



name = "wht_2_1_1-1",
applicable ={
	exp = "a",
	a = true
},
attribute = "attack",
timeout = 99999
}
