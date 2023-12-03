module(..., package.seeall)


-- 时间延迟参数
delayTime = 3 			--  吸球丢球状态延迟时间

attackOrDefDelaytime = 5 		-- 确认进攻与防守转换的状态延迟时间

gradBallByEnemyDelaytime = 5 	-- 确认敌方已抢到球的状态延迟时间

-- directBallCarryTime = 300   	--任意球带球持续帧数(禁区附近)
-- ballCarryTime = 300  		--共用代码部分带球持续帧数(其他位置)

notBallPassDelayTime = 30       --判断球的方向是否已经偏离传球线延迟帧数(大点好,在开始及结束前会出现满足条件的现象)

control = 30   --用来走位是否到达的判断精度(play.totarget(role))

kickoffballSpeed = 500 --判断球是否静止(大于此速度时说明对方已开球)



--通用函数层面的参数

-- 判断进攻还是防守参数
attaOrDefDist = 300	--都未得球时，计算进攻还是防守，两者至少要保持的距离 
attaOrDefBallSpeed =500-- 且要满足球速低于某个值，
ballToRoleDist = 120		-- 球离对方机器人在设定值内,认为球能被它抢到

subDist = 20 -- 双方距离球的相差值, 我方减敌方的值,大于此值表示被抢

wirlsubDist = 10 -- 双方距离球的相差值, 很接近表示正在争球
wirlBallSpeed = 500 -- 双方争球时,球速应该很低


--判断球是否在移动
passAccuracy = 0.1	-- 球的移动方向 和 球与角色的方向 相减,二者偏差在设定范围内,表示球向角色移动
						-- 0.1 表示大约5度
ballVelMod   =  500	-- 球速大于设定值,结合passAccuracy,表示在传球
ball2Enemy  =  140  	--结合球离开对方的持球机器人，表示在传球

noPassAccuracy = 0.2    -- 球的移动方向 和 球与角色的方向 相减,二者偏差大于设定范围,表示球被对方抢走或丢失



-- 持球机器人一直持球，直到发现接球机器人某个范围内没有对方机器人,且满足本身附近有至少2个的对方机器人，可以进行传球
--- 接球机器人某个范围内有是否有对方机器人(用来判断是否传球)
enemyIndist = 1300  
--- 持球机器人某个范围内有对方机器人是否至少有2个(用来判断是否传球)
enemyIndist1 = 2200  




--技能及部分函数的参数
-- 1. 截球参数 
moveSpeed1 = 2500 -- 大于此速度,移动到垂直点
moveSpeed2 = 1500 -- 大于此速度,向球移动到距离distToBall,小于此速度,直接向球移动吸球
distToBall = 200



--2.  跑位
canPassDist = 150 			--是否能传球的阻挡距离
roleToCenter =  3000 		 --走位时，机器人与中心点的距离 


--3.  传球
canFlatDist  = 150   --传球阻挡距离



--4. 带球参数
-- crarryDist = 30 --是否到达目标点的判断精度

-- crarryBallSpeed = 1000 --仿真时的带球速度
-- crarryBallSpeed1 = 1000 --实地时的带球速度

-- crarryRadius = 800 	--轨迹圆的半径
-- crarryDir    = 3*math.pi/4	--轨迹圆的初始弧度


--5.  抢球参数
grabBallSpeed = 1500 -- 球速高于设定值时,直接向球的前面位置跑
grabToBallDist = 300 -- 球在移动时,移动目标到离球设定值
grabBlockDist = 120  -- 对方机器人离抢球直线的垂直距离,小于设定值为阻挡直线抢球
grabBalltoRole = 200 -- 对方机器人离球的距离小于设定值时,说明球被对方得到,绕过对方机器人去抢球
grabRoundDist = 300 	--绕行离球距离

nearToRoleDist = 170    --另一个抢球技能(逼近对方的距离)



--6. 旋转参数
whirlSpeed = 3 -- 吸球状态时逆时针旋转速度
whirlSpeed1 = -3 -- 吸球状态时顺时针旋转速度

whirlSimulationSpeed = 3 -- 吸球状态时逆时针旋转速度
whirlSimulationSpeed1 = -3 -- 吸球状态时顺时针旋转速度

detAngle = 0.2 --控制绕球旋转的角速度
whirlDist = 200--绕球旋转时，离球的距离

whirlArcToPassBall = 0.02 -- 机器人弧度与传球目标点的比较,相差在设定值内表示旋转完成.0.02大约1度
whirlArcCompare = 0.2 -- 球与我方机器人弧度 和 球与对方机器人的比较,相差在设定值内表示旋转完成（抢球旋转）.




--7. 协防参数
helpDefDist = 300        		--协防时,与被防守机器人的距离
exceptDist1   =  500			--对方机器人离球的距离在设定值内,认为它是抢球机器人
					-- 判断有没有对方机器人进入此范围内 





-- 力度设置	
-- 仿真公式 	 ball.pos():dist(ipos)*1 + 1000 
			--ball.pos():dist(ipos)*parameter.simulationTimes + parameter.simulationCompensate
simulationTimes = 1.2
simulationCompensate = 2000
simulationMinPower = 3000 --仿真最小力度
simulationMaxPower = 6400 --仿真最大力度
-- 实地公式 	 ball.pos():dist(ipos)*0.1+100
			--ball.pos():dist(ipos)*parameter.realTimes + parameter.realCompensate
realTimes = 0.05
realCompensate = 80
realMinPower = 250
realMaxPower = 500
-- 挑球公式	 ball.pos():dist(ipos) * 0.58 
			--ball.pos():dist(ipos) * parameter.chipTimes
-- 仿真
simulationChipTimes = 1.0
-- simulationChipCompensate = 100,
simulationChipMinPower = 500  --挑球的最小力度
simulationChipMaxPower = 2500  --挑球的最大力度
-- 实地
realChipTimes = 0.5 
realChipMinPower = 500  --挑球的最小力度	
realChipMaxPower = 2200  --挑球的最大力度
















