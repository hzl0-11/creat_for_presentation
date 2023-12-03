--避球又避车
local DSS_FLAG_all = flag.allow_dss + flag.dodge_ball  

--只避车
local DSS_FLAG_onlyRobot = flag.allow_dss



--测试判断距离精度和碰球的帧数
--测试prepareShootPos(250,100,150)
--   prepareShootPos(dist,shootPos2EdgeDist)  直接射门时,寻找准备射门的位置
                    -- dist 离球的距离
                    -- shootPos2EdgeDist 射门目标点离球门边框的距离 
                    -- enemy2ShootLineDist 对方机器人离射门线的垂直距离,距离内说明能挡住射门线


gPlayTable.CreatePlay{
firstState = "prepare",

--第一个状态不能直接引用角色名(除非config文件中已指定),所以附加一个状态
["prepare"] = {
    switch = function() 
            if bufcnt(true,1) then                         
                return "prepare1"
            end
    end,
    a = whtCommonTask.stop(),
    match = "{a}"
},

-- 直接向球附近的某点跑位
["prepare1"] = {
    switch = function() 
            if bufcnt(player.toTargetDist("a") < 50  ,10) then                         
                return "prepareAroundBall"
            end
    end,

    a = whtCommonTask.goCmuRush(whtAttackFunction.prepareAroundBallPos("a",150), dir.playerToBall,_, DSS_FLAG_all),
	match = "{a}"
},

["prepareAroundBall"] = {
    switch = function() 
        -- if math.abs(player.toTheirGoalDir("a")-dir.playerToBall("a")) < 0.2 then                                             
        --         return "prepareShoot"
        -- end
        if bufcnt(player.toTargetDist("a") < 50  ,2) then                                            
                return "prepareShoot"
        end
    end,

    a = whtAttackTask.roundBallToShoot("a",130),
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



name = "wht_2_1_1-2",
applicable ={
	exp = "a",
	a = true
},
attribute = "attack",
timeout = 99999
}
