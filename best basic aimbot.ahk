#NoEnv
#SingleInstance, Force
#Persistent
#InstallKeybdHook
#UseHook
#KeyHistory, 0
#HotKeyInterval 1
#MaxHotkeysPerInterval 127
SetKeyDelay,-1, -1
SetControlDelay, -1
SetMouseDelay, -1
SetWinDelay,-1
SendMode, InputThenPlay
SetBatchLines,-1
ListLines, Off
CoordMode, Pixel, screen


DllCall("QueryPerformanceFrequency", "Int64*", freq)
FlickBefore := 0


aim_key := "RButton" ;List of Keys: https://www.autohotkey.com/docs/KeyList.htm

game_sens := 0.31 ;Game sens
game_fov  := 103 ;Game fov
game_fps  := 84 ;Display refresh rate


;use this tool and set sensitivity and dpi to 1, then copy In/360 value https://gamingsmart.com/mouse-sensitivity-converter
;Apex Legends: 16363.64
;CSGO: 16363.64
;Halo Infinite: 17454.6
full360 := 16363.64/game_sens ;Modify it to the value of the corresponding game

EMCol := 0x56007D ;Enemy color
ColVn := 10 ;Variation
OffsetX := 0
OffsetY := 4
ZeroX := Floor(A_ScreenWidth  // 2) - OffsetX
ZeroY := Floor(A_ScreenHeight // 2) - OffsetY
CFovX := deg2coord(20, game_fov, A_ScreenWidth, A_ScreenHeight) ;aimbot fov x. range: 0 ~ game_fov/2
CFovY := deg2coord(20, game_fov, A_ScreenWidth, A_ScreenHeight) ;aimbot fov y. range: 0 ~ game_fov/2
SpeedX := 0.5 ;aimbot speed. range: 0 ~ 1
SpeedY := 0.5 ;aimbot speed. range: 0 ~ 1
ScanL := ZeroX - CFovX
ScanT := ZeroY - CFovY
ScanR := ZeroX + CFovX
ScanB := ZeroY + CFovY


Loop {
    KeyWait, %aim_key%, D
    AimPixel := _PixelSearch(ScanL, ScanT, ScanR, ScanB, EMCol, ColVn)
    if (!ErrorLevel) {
        AimX := AimPixel[1] - ZeroX
        ,AimY := AimPixel[2] - ZeroY
        ,MoveX := Floor(coord2deg(AimX, game_fov, A_ScreenWidth, A_ScreenHeight) * (full360/360) * SpeedX)
        ,MoveY := Floor(coord2deg(AimY, game_fov, A_ScreenWidth, A_ScreenHeight) * (full360/360) * SpeedY)
        DllCall("QueryPerformanceCounter", "Int64*", FlickAfter)
        if ((FlickAfter-FlickBefore)/freq*1000 >= 1000/game_fps) {
            DllCall("QueryPerformanceCounter", "Int64*", FlickBefore)
            DllCall("mouse_event", "uint", 0x0001, "uint", MoveX, "uint", MoveY, "uint", 0, "int", 0)
        }
    }
}

;full360 test
/*
F::
DllCall("mouse_event", "uint", 0x0001, "uint", 6666, "uint", 0, "uint", 0, "int", 0)
return
*/

_PixelSearch(X1, Y1, X2, Y2, ColorID, Variation:=0) {
    PixelSearch, OutputVarX, OutputVarY, X1, Y1, X2, Y2, ColorID, Variation, Fast RGB
    Return [OutputVarX, OutputVarY]
}

deg2rad(degrees) {
    return degrees * ((4*ATan(1)) / 180)
}

rad2deg(radians) {
    return radians * (180 / (4*ATan(1)))
}

coord2deg(delta, fov, winwidth, winheight) {
    ;lookAt := delta * 2 / winwidth
    ;return rad2deg(atan(lookAt*tan(deg2rad(fov*0.5)))) ;degrees
    return rad2deg(atan(((delta<<1)/winwidth)*tan(deg2rad(fov*0.5))))
}

deg2coord(delta, fov, winwidth, winheight) {
    return winwidth*0.5/tan(deg2rad(fov*0.5))*tan(deg2rad(delta))
}

;Apex Legends must use this conversion
RealFov(fov, winwidth, winheight) {
    raspectRatio := (winwidth/winheight)/(4/3)
    return 2*rad2deg(atan(tan(deg2rad(fov*0.5))*raspectRatio))
}




F6::reload
F7::Exitapp
