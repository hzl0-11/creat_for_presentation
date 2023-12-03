module(..., package.seeall)

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








shootPre = 0.02    --射门角度对准的偏差范围，大约为1度

roundBallSpeed = 20  --绕球旋转速度（每帧20度）
-- detAngle 	= 0.1 --控制绕球旋转的角速度(弧度为单位)  0.1 表示大约5度
CSroundBallSpeed = 20  --速度控制下绕球旋转初始速度（每帧20度）





--6. 旋转参数
whirlSpeed = 3 -- 吸球状态时逆时针旋转速度
whirlSpeed1 = -3 -- 吸球状态时顺时针旋转速度

whirlSimulationSpeed = 3 -- 吸球状态时逆时针旋转速度
whirlSimulationSpeed1 = -3 -- 吸球状态时顺时针旋转速度

whirlArcToShoot = 0.04 -- 机器人弧度与射门目标点的比较,相差在设定值内表示旋转完成.0.02大约1度
			--  不减速旋转，精度设的低点	
initSpeed = 3  --速度控制旋转初始化速度
CSwhirlArcToShoot = 0.01 -- 在速度控制下，精度可以达到很高 
























