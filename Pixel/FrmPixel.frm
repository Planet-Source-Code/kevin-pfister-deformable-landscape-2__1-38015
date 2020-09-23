VERSION 5.00
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "MSCOMCTL.OCX"
Begin VB.Form FrmPixel 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Pixel Test (Click and drag, use slider to increase/decrease size)"
   ClientHeight    =   8595
   ClientLeft      =   45
   ClientTop       =   330
   ClientWidth     =   7650
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   8595
   ScaleWidth      =   7650
   StartUpPosition =   2  'CenterScreen
   Begin VB.CommandButton CmdLand 
      Caption         =   "Generate  Image"
      Height          =   375
      Left            =   2280
      TabIndex        =   6
      Top             =   8160
      Width           =   1455
   End
   Begin VB.PictureBox PicMap 
      AutoRedraw      =   -1  'True
      Height          =   7575
      Left            =   0
      ScaleHeight     =   501
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   501
      TabIndex        =   5
      Top             =   0
      Width           =   7575
   End
   Begin VB.CommandButton CmdRanBumps 
      Caption         =   "Ran Bumps"
      Height          =   375
      Left            =   1200
      TabIndex        =   4
      Top             =   8160
      Width           =   975
   End
   Begin MSComctlLib.Slider Slider1 
      Height          =   375
      Left            =   3840
      TabIndex        =   3
      Top             =   8160
      Width           =   3735
      _ExtentX        =   6588
      _ExtentY        =   661
      _Version        =   393216
      Min             =   1
      Max             =   50
      SelStart        =   20
      Value           =   20
   End
   Begin VB.CommandButton CmdGenNew 
      Caption         =   "!!Generate Map!!"
      Height          =   375
      Left            =   120
      TabIndex        =   2
      Top             =   7680
      Width           =   2055
   End
   Begin MSComctlLib.ProgressBar Pb 
      Height          =   375
      Left            =   2280
      TabIndex        =   1
      Top             =   7680
      Width           =   5295
      _ExtentX        =   9340
      _ExtentY        =   661
      _Version        =   393216
      Appearance      =   1
      Max             =   1000
   End
   Begin VB.CommandButton CmdRanHoles 
      Caption         =   "Ran Holes"
      Height          =   375
      Left            =   120
      TabIndex        =   0
      Top             =   8160
      Width           =   975
   End
End
Attribute VB_Name = "FrmPixel"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'Pixel Test
'By Kevin Pfister

'Creates a deformable map and allows you to edit it, Very Fast uses GetPixel
'and SetPixelV. Also it only draws what is different to that onscreen so it
'is faster. Even Faster when compiled!!




Private Declare Function SetPixelV Lib "gdi32" (ByVal hdc As Long, ByVal X As Long, ByVal Y As Long, ByVal Color As Long) As Byte
Private Declare Function LineTo Lib "gdi32" (ByVal hdc As Long, ByVal X As Long, ByVal Y As Long) As Long
Private Declare Function MoveToEx Lib "gdi32" (ByVal hdc As Long, ByVal X As Long, ByVal Y As Long, lpPoint As Any) As Long

Dim map(1 To 500, 1 To 500)
Dim lastDraw(1 To 500, 1 To 500)

Private Sub CmdGenNew_Click()
    NewMap  'Creates a new map
    DrawAll 'Draw the complete picture
End Sub

Private Sub CmdLand_Click()
    Dim X As Integer
    Dim Y As Integer
    Dim Mult As Integer
    Dim YPlus As Integer
    Dim YDiv As Integer
    YPlus = 40
    YDiv = 2
    Mult = 1
    FrmLand.Show
    FrmLand.Cls
    For Y = 1 To 500
        For X = 1 To 500
            If map(X, Y) > 2 Then   'Draw Grass
                NewDraw = RGB(0, 100 + map(X, Y) * 4, 0)  'Calc Colour
                FrmLand.Line (X, Y / YDiv - map(X, Y) * Mult + YPlus)-(X, Y / YDiv - map(X, Y) * Mult + YPlus + 5), NewDraw
            ElseIf map(X, Y) > 0 And map(X, Y) < 2 Then 'Draw Sand
                NewDraw = RGB(170 + map(X, Y) * 4, 160 + map(X, Y) * 4, 70 + map(X, Y) * 4) 'Calc Colour
                SetPixelV FrmLand.hdc, X, Y / YDiv - map(X, Y) * Mult + YPlus, NewDraw
             Else    'Draw Water
                NewDraw = RGB(0, 0, 100 + Abs(map(X, Y)) * 2)    'Calc Colour
                SetPixelV FrmLand.hdc, X, Y / YDiv + YPlus, NewDraw 'Draw to Screen
            End If
        Next
        FrmLand.Refresh
    Next
End Sub

Private Sub CmdRanBumps_Click()
    Pb.Max = 50 'Set Progressbar max to 50
    Pb.Value = 0
    For a = 1 To 50 'Make 50 Bumps
        Pb.Value = Pb.Value + 1
        X = Int(Rnd * 700) - 100 'Random X Postion(Larger than screen so it overlaps)
        Y = Int(Rnd * 700) - 100 'Random Y Postion(Larger than screen so it overlaps)
        Rad = Int(Rnd * 50) + 1 'Random Size
        Call PHit(X, Y, Rad)    'Call the (P)lus Hit Subroutine
    Next
End Sub

Private Sub CmdRanHoles_Click()
    Pb.Max = 50 'Set Progressbar max to 50
    Pb.Value = 0
    For a = 1 To 50 'Make 50 Holes
        Pb.Value = Pb.Value + 1 'Increase Progressbar value
        X = Int(Rnd * 500)  'Random X Postion
        Y = Int(Rnd * 500)  'Random Y Postion
        Rad = Int(Rnd * 50) + 1 'Random Size
        Call Mhit(X, Y, Rad)    'Call the (M)inus Hit Subroutine
    Next
End Sub

Private Sub Form_Load()
    Randomize Timer 'Make random
End Sub

Sub NewMap()    'Create a new map
    Pb.Max = 500    'Set Progressbar max to 50
    Pb.Value = 0
    For X = 1 To 500
        Pb.Value = Pb.Value + 1
        For Y = 1 To 500
            map(X, Y) = Sin(X / 32) * 20 + Sin(Y / 32) * 20 - 20    'Using this for fun, can be anything
        Next
    Next
End Sub

Sub Draw(Xmin, Xmax, YMin, YMax)    'Redraw a certain area
    For X = Xmin To Xmax
        For Y = YMin To YMax
            If map(X, Y) > 2 Then   'Draw Grass
                NewDraw = RGB(0, 100 + map(X, Y) * 4, 0)     'Calc Colour
                If NewDraw <> lastDraw(X, Y) Then   'Only draw if different Colour
                    SetPixelV PicMap.hdc, X, Y, NewDraw 'Draw to Screen
                    lastDraw(X, Y) = NewDraw    'Set the new colour
                End If
            ElseIf map(X, Y) > 0 And map(X, Y) < 2 Then 'Draw Sand
                NewDraw = RGB(170 + map(X, Y) * 4, 160 + map(X, Y) * 4, 70 + map(X, Y) * 4)  'Calc Colour
                If NewDraw <> lastDraw(X, Y) Then  'Only draw if different Colour
                    SetPixelV PicMap.hdc, X, Y, NewDraw  'Draw to Screen
                    lastDraw(X, Y) = NewDraw    'Set the new colour
                End If
            Else    'Draw Water
                NewDraw = RGB(0, 0, 100 + Abs(map(X, Y)) * 2)   'Calc Colour
                If NewDraw <> lastDraw(X, Y) Then  'Only draw if different Colour
                    SetPixelV PicMap.hdc, X, Y, NewDraw 'Draw to Screen
                    lastDraw(X, Y) = NewDraw    'Set the new colour
                End If
            End If
        Next
    Next
    PicMap.Refresh  'Refresh the screen
End Sub

Sub DrawAll()   'Draw all of the pic
    For X = 1 To 500
        For Y = 1 To 500
            If map(X, Y) > 2 Then   'Draw Grass
                NewDraw = RGB(0, 100 + map(X, Y) * 4, 0)     'Calc Colour
                SetPixelV PicMap.hdc, X, Y, NewDraw 'Draw to Screen
                lastDraw(X, Y) = NewDraw    'Set the new colour
            ElseIf map(X, Y) > 0 And map(X, Y) < 2 Then 'Draw Sand
                NewDraw = RGB(170 + map(X, Y) * 4, 160 + map(X, Y) * 4, 70 + map(X, Y) * 4)  'Calc Colour
                SetPixelV PicMap.hdc, X, Y, NewDraw 'Draw to Screen
                lastDraw(X, Y) = NewDraw    'Set the new colour
            Else    'Draw Water
                NewDraw = RGB(0, 0, 100 + Abs(map(X, Y)) * 2)    'Calc Colour
                SetPixelV PicMap.hdc, X, Y, NewDraw 'Draw to Screen
                lastDraw(X, Y) = NewDraw    'Set the new colour
            End If
        Next
    Next
    PicMap.Refresh 'Refresh the screen
End Sub

Sub Mhit(X, Y, Rad) 'Minus Hit
    For XSize = X - Rad To X + Rad
        For YSize = Y - Rad To Y + Rad
            If XSize > 0 And XSize < 500 Then   'Only Calc if in array
                If YSize > 0 And YSize < 500 Then   'Only Calc if in array
                    minus = Sin((XSize - (X - Rad)) / (Rad / 2)) + Sin((YSize - (Y - Rad)) / (Rad / 2))
                    'Use sin to make a circle effect and take away the positive values
                    If minus > 1 Then   'Take away only positive values(above 1)
                        map(XSize, YSize) = map(XSize, YSize) - (minus * 5 - 5) 'Alter Array
                    End If
                End If
            End If
        Next
    Next
    Call Calc(X, Y, Rad)    'Calc what size to redraw
End Sub

Sub PHit(X, Y, Rad) 'Plus Hit
    For XSize = X - Rad To X + Rad
        For YSize = Y - Rad To Y + Rad
            If XSize > 0 And XSize < 500 Then 'Only Calc if in array
                If YSize > 0 And YSize < 500 Then 'Only Calc if in array
                    Plus = Sin((XSize - (X - Rad)) / (Rad / 2)) + Sin((YSize - (Y - Rad)) / (Rad / 2))
                    'Use sin to make a circle effect and add the positive values
                    If Plus > 1 Then
                        map(XSize, YSize) = map(XSize, YSize) + (Plus * 5 - 5)
                    End If
                End If
            End If
        Next
    Next
    Call Calc(X, Y, Rad)    'Calc what size to redraw
End Sub

Sub Calc(X, Y, Rad) 'Calc what size to redraw
    Xmin = X - Rad
    Xmax = X + Rad
    YMin = Y - Rad
    YMax = Y + Rad
    If Xmin < 1 Then
        Xmin = 1
    End If
    If Xmax > 500 Then
        Xmax = 500
    End If
    If YMin < 1 Then
        YMin = 1
    End If
    If YMax > 500 Then
        YMax = 500
    End If
    Call Draw(Xmin, Xmax, YMin, YMax)   'Redraw the new area
End Sub

Private Sub PicMap_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
    If Button = 1 Then
        Rad = Slider1.Value
        Call Mhit(X, Y, Rad)    'Edit area
    ElseIf Button = 2 Then
        Rad = Slider1.Value
        Call PHit(X, Y, Rad)    'Edit area
    End If
End Sub
