module(..., package.seeall)

-- 时间延迟参数
delayTime = 5 			--  吸球/丢球状态延迟时间

attackOrDefDelaytime = 5 		-- 确认进攻与防守转换的状态延迟时间

gradBallByEnemyDelaytime = 5 	-- 确认敌方已抢到球的状态延迟时间

directBallCarryTime = 300   	--任意球带球持续帧数(禁区附近)
ballCarryTime = 300  		--共用代码部分带球持续帧数(其他位置)

notBallPassDelayTime = 60       --判断球的方向是否已经偏离传球线延迟帧数(大点好,在开始及结束前会出现满足条件的现象)



kickoffballSpeed = 500 --判断球是否静止(大于此速度时说明对方已开球)



--角度/位置精度参数
control = 50   --用来走位是否到达的判断精度(play.totarget(role))
controlDist = 50   --用来走位是否到达的判断精度(play.totarget(role))




--距离参数





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

--任意球策略参数
frontOrBack = -2*param.pitchLength/24  ---前后场任意球的分界点，和任意球接球走位有关


-- 判断多少个对方机器人在指定机器人的一定范围内(判断传球优先指标：能传球且周围对方机器人最少)
directEnemy2PlayDist = 1000    ----任意球传球判断
enemy2PlayDist = 600           ---- 过程传球判断
-- ballMoveMod =  2000    -- 判断能否传球时,机器人速度不能过快

-- 判断多少个机器人在球的一定范围内
roleIndist1 = 200     --- 设定范围内有多少机器人(用来判断吸球旋转(抢球模式），否则表示抢球成功可以传球，射门等
roleIndist2 = 500    --- 设定范围内有多少机器人(用来判断运球优先还是传球等优先)




--技能及部分函数的参数
-- 1. 截球参数 
moveSpeed1 = 2500 -- 大于此速度,移动到垂直点
moveSpeed2 = 1500 -- 大于此速度,向球移动到距离distToBall,小于此速度,直接向球移动吸球
distToBall = 200



--2.  跑位
canDirectDist = 2500 		--判断能不能射门时，设定离球门中点的圆弧半径
canFlatShootDist = 150 		--是否能射门的阻挡距离
canPassDist = 150 			--是否能传球的阻挡距离

--3.  传球
canFlatDist  = 150   --传球阻挡距离



--4. 带球参数
crarryDist = 30 --是否到达目标点的判断精度

crarryBallSpeed = 1000 --仿真时的带球速度
crarryBallSpeed1 = 1000 --实地时的带球速度

crarryRadius = 800 	--轨迹圆的半径
crarryDir    = 3*math.pi/4	--轨迹圆的初始弧度


--5.  抢球参数
grabBallSpeed = 1500 -- 球速高于设定值时,直接向球的前面位置跑
grabToBallDist = 300 -- 球在移动时,移动目标到离球设定值
grabBlockDist = 120  -- 对方机器人离抢球直线的垂直距离,小于设定值为阻挡直线抢球
grabBalltoRole = 200 -- 对方机器人离球的距离小于设定值时,说明球被对方得到,绕过对方机器人去抢球
grabRoundDist = 300 	--绕行离球距离



--6. 旋转参数
whirlSpeed = 3 -- 吸球状态时逆时针旋转速度
whirlSpeed1 = -3 -- 吸球状态时顺时针旋转速度

whirlSimulationSpeed = 3 -- 吸球状态时逆时针旋转速度
whirlSimulationSpeed1 = -3 -- 吸球状态时顺时针旋转速度

whirlArcToShoot = 0.04 -- 机器人弧度与射门目标点的比较,相差在设定值内表示旋转完成.0.02大约1度
			--  不减速旋转，精度设的低点	
initSpeed = 3  --速度控制旋转初始化速度
CSwhirlArcToShoot = 0.02 -- 在速度控制下，精度可以达到很高 

roundBallSpeed = 20  --绕球旋转速度（每帧20度）
CSroundBallSpeed = 20  --速度控制下绕球旋转初始速度（每帧20度）
CSroundBallToShoot = 0.04


whirlArcToPassBall = 0.04 -- 机器人弧度与传球目标点的比较,相差在设定值内表示旋转完成.0.02大约1度
detAngle = 0.2 --控制绕球旋转的角速度
whirlDist = 200--绕球旋转时，离球的距离
whirlArcCompare = 0.2 -- 球与我方机器人弧度 和 球与对方机器人的比较,相差在设定值内表示旋转完成（抢球旋转）.
needWhirlRobotDist = 1000 --如有对方机器人在设定距离范围内，判别是否旋转完成，否则直接返回完成
--部分用到了前进参数


shootDistX = 5*param.pitchLength/24


--8. 防守
-- 后防
autoShootDist = 300  --防守时,球离防守机器人小于300时,主动拿球踢球




-- 协防参数
helpDefDist = 300        		--协防时,与被防守机器人的距离
exceptDist1   =  500			--对方机器人离球的距离在设定值内,认为它是抢球机器人
					-- 判断有没有对方机器人进入此范围内 
exceptDist2	  = 4*param.pitchLength /24--对方机器人位置大于设定值,认为它是防守机器人
exceptDist3	  = -10*param.pitchLength /24--对方机器人位置小于设定值,认为它是干绕机器人

defToAttackStopPos = {            -- 有多余防守队员时,移位到进攻位置
        CGeoPoint:new_local(8*param.pitchLength/24,4*param.pitchWidth/18),
        CGeoPoint:new_local(8*param.pitchLength/24,-4*param.pitchWidth/18)        
			} 


--9. 前进参数
advanceDist = 1500    -- 前进时,需要判断的距离
canAdvanceDist = 500  -- 前进线路上的垂直单向距离范围
canRoundDist = 300  -- 四周的距离范围
					 --以上三个参数用来判断能不能向前前进
advancePoint1 = CGeoPoint:new_local(param.pitchLength/2,4*param.pitchWidth/12)
advancePoint2 = CGeoPoint:new_local(param.pitchLength/2,-4*param.pitchWidth/12)
				--以上二个参数用来定义前进目标参考点
advancePre = 0.1    --旋转到前进方向的判断精度，大约5度	




--点球参数
--防守方
speed2Penalty = 200   	--大点球时，球速高于设定值，防守球的移动方向
-- 进攻方
canShootPenaltyDist1 = 6*param.pitchLength/24 --球的X坐标大于其时，可以射门(对方防守底线)
canShootPenaltyDist2 = 7*param.pitchLength/24 --球的X坐标大于其时，可以射门	(对方防守禁区内)
canShootPenaltyDist3 = param.pitchLength/24 --球的X坐标大于其时，可以射门(对方出击)
b2GDist = 2000 --球离对方守门员的距离，小于此距离可以挑射(对方出击时使用)
canFlatPenaltyShootDist = 120  --是否能平射的阻挡距离
-- 大点球推球前进（advance1)
penaltyAdvancePower = 2000     -- 防真时踢球前进的力量
penaltyAdvanceRealPower = 150	-- 场地时踢球前进的力量
penaltyAdvanceObjectPoint = CGeoPoint:new_local(param.pitchLength/2,0) --向前推的目标点
penaltyAdvancePre = 5   --角度对准的偏差范围，单位为度




--放球参数
--防守方
 directDefStopPos = {            -- 防守方任意球防守初始站位
        CGeoPoint:new_local(-7*param.pitchLength/24,5*param.pitchWidth/18),
        CGeoPoint:new_local(-7*param.pitchLength/24,-5*param.pitchWidth/18),
        CGeoPoint:new_local(-8*param.pitchLength/24,-100)        
			}
beginMoveDist = 1000   		-- 运行到离球设定距离后，其他机器人开始跑位  



-- 力度设置	
-- 仿真公式 	 ball.pos():dist(ipos)*1 + 1000 
			--ball.pos():dist(ipos)*parameter.simulationTimes + parameter.simulationCompensate
simulationTimes = 1.2
simulationCompensate = 1000
simulationMinPower = 2000 --仿真最小力度
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
















