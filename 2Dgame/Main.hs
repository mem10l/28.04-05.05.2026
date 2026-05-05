module Main where

import Graphics.Gloss
import Graphics.Gloss.Interface.Pure.Game
import Data.Set (Set)
import qualified Data.Set as Set

-- ============================================================
-- TYPES
-- ============================================================

data Platform = Platform
  { platX :: Float
  , platY :: Float
  , platW :: Float
  , platH :: Float
  }

data Coin = Coin
  { coinX    :: Float
  , coinY    :: Float
  , coinAnim :: Float   -- rotation angle for spin effect
  , coinTaken :: Bool
  }

data World = World
  { playerX  :: Float
  , playerY  :: Float
  , velX     :: Float
  , velY     :: Float
  , onGround :: Bool
  , cameraX  :: Float   -- camera offset (scrolls with player)
  , score    :: Int
  , coins    :: [Coin]
  , heldKeys :: Set Key
  , gameOver :: Bool
  , platforms :: [Platform]
  }

-- ============================================================
-- CONSTANTS
-- ============================================================

gravity      :: Float; gravity      = -0.6
jumpStrength :: Float; jumpStrength = 13
moveSpeed    :: Float; moveSpeed    = 4
friction     :: Float; friction     = 0.8
playerW      :: Float; playerW      = 28
playerH      :: Float; playerH      = 28
screenW      :: Float; screenW      = 800
screenH      :: Float; screenH      = 600

-- ============================================================
-- LEVEL DATA
-- ============================================================

levelPlatforms :: [Platform]
levelPlatforms =
  -- ground segments
  [ Platform (-400) (-200) 300 20
  , Platform   (-50) (-200) 200 20
  , Platform   300  (-200) 400 20
  , Platform   800  (-200) 300 20
  , Platform  1200  (-200) 500 20
  -- floating platforms
  , Platform (-300) (-80)  120 16
  , Platform  (-80) ( 20)  100 16
  , Platform   150  (-50)  130 16
  , Platform   350   (60)  100 16
  , Platform   520  (-20)  110 16
  , Platform   700   (80)  120 16
  , Platform   900   (20)  130 16
  , Platform  1050   (90)  100 16
  , Platform  1200  (-80)  110 16
  , Platform  1350   (50)  120 16
  -- high platforms
  , Platform   200  180   80  16
  , Platform   400  160  100  16
  , Platform   600  200   90  16
  , Platform   900  180   80  16
  , Platform  1100  170  100  16
  ]

levelCoins :: [Coin]
levelCoins =
  map (\(x,y) -> Coin x y 0 False)
  [ (-250, -50), (-200,  10), (-100,  60)
  , (  50,  80), ( 160,  20), ( 250, 100)
  , ( 370, 130), ( 500,  60), ( 600, 150)
  , ( 720, 160), ( 800,  90), ( 910,  90)
  , (1000, 160), (1060, 170), (1200, -20)
  , (1300, 130), (1400, 120), ( 210, 260)
  , ( 400, 240), ( 620, 280)
  ]

-- ============================================================
-- INITIAL WORLD
-- ============================================================

initialWorld :: World
initialWorld = World
  { playerX   = -300
  , playerY   = -150
  , velX      = 0
  , velY      = 0
  , onGround  = False
  , cameraX   = 0
  , score     = 0
  , coins     = levelCoins
  , heldKeys  = Set.empty
  , gameOver  = False
  , platforms = levelPlatforms
  }

-- ============================================================
-- INPUT
-- ============================================================

handleInput :: Event -> World -> World
handleInput (EventKey (Char 'r') Down _ _) _ = initialWorld   -- ← first
handleInput (EventKey k Down _ _) w = w { heldKeys = Set.insert k (heldKeys w) }
handleInput (EventKey k Up   _ _) w = w { heldKeys = Set.delete k (heldKeys w) }
handleInput _ w = w

isHeld :: World -> Key -> Bool
isHeld w k = Set.member k (heldKeys w)

-- ============================================================
-- COLLISION HELPERS
-- ============================================================

-- AABB: does player overlap with a platform?
overlaps :: Float -> Float -> Platform -> Bool
overlaps px py p =
  px + playerW/2 > platX p - platW p/2 &&
  px - playerW/2 < platX p + platW p/2 &&
  py + playerH/2 > platY p - platH p/2 &&
  py - playerH/2 < platY p + platH p/2

-- Land on top of a platform (feet just above top surface)
landedOn :: Float -> Float -> Float -> Platform -> Bool
landedOn px py vy' p =
  vy' <= 0 &&
  px + playerW/2 - 4 > platX p - platW p/2 &&
  px - playerW/2 + 4 < platX p + platW p/2 &&
  py - playerH/2 <= platY p + platH p/2 + 2 &&
  py - playerH/2 >= platY p - platH p/2

-- ============================================================
-- PHYSICS UPDATE
-- ============================================================

updateWorld :: Float -> World -> World
updateWorld _ w
  | gameOver w = w   -- freeze on death

  | otherwise =
      let
        -- ---- horizontal movement ----
        leftHeld  = isHeld w (Char 'a') || isHeld w (SpecialKey KeyLeft)
        rightHeld = isHeld w (Char 'd') || isHeld w (SpecialKey KeyRight)
        jumpHeld  = isHeld w (Char 'w') || isHeld w (Char ' ')
                  || isHeld w (SpecialKey KeyUp) || isHeld w (SpecialKey KeySpace)

        targetVx = if leftHeld then -moveSpeed
                   else if rightHeld then moveSpeed
                   else 0
        -- smooth acceleration / friction
        newVx = if targetVx /= 0
                then targetVx
                else velX w * friction

        -- ---- vertical movement (gravity) ----
        newVy0 = velY w + gravity

        -- ---- jump (only when grounded) ----
        (newVy1, nowGrounded0) =
          if jumpHeld && onGround w
          then (jumpStrength, False)
          else (newVy0, False)   -- nowGrounded is reset; set properly after collision

        -- ---- new candidate position ----
        newX0 = playerX w + newVx
        newY0 = playerY w + newVy1

        -- ---- platform collision ----
        plats = platforms w

        -- Check landing on top
        (newY1, newVy2, grounded) =
          case filter (landedOn newX0 newY0 newVy1) plats of
            (p:_) -> (platY p + platH p/2 + playerH/2, 0, True)
            []    -> (newY0, newVy1, False)

        -- Simple head-bump (hitting underside of platform)
        newVy3 =
          case filter (overlaps newX0 newY1) plats of
            (p:_) | newVy2 > 0 -> -1   -- bump head
            _                  -> newVy2

        -- Clamp X against very thick platform sides (optional, keeps it simple)
        newX1 = newX0

        -- ---- death pit ----
        dead = newY1 < -400

        -- ---- camera: follow player with some lag ----
        targetCam = playerX w - screenW * 0.3
        newCam    = cameraX w + (targetCam - cameraX w) * 0.1

        -- ---- coin collection ----
        collectRadius = 25
        collect c = not (coinTaken c) &&
                    abs (coinX c - newX1) < collectRadius &&
                    abs (coinY c - newY1) < collectRadius

        newCoins = map (\c -> if collect c then c { coinTaken = True } else c) (coins w)
        gained   = length (filter collect (coins w))

        -- ---- animate uncollected coins ----
        animCoins = map (\c -> c { coinAnim = coinAnim c + 3 }) newCoins

      in w
          { playerX  = newX1
          , playerY  = newY1
          , velX     = newVx
          , velY     = newVy3
          , onGround = grounded
          , cameraX  = newCam
          , score    = score w + gained * 10
          , coins    = animCoins
          , gameOver = dead
          }

-- ============================================================
-- RENDERING
-- ============================================================

-- Sky gradient approximation (layered rectangles)
drawSky :: Picture
drawSky = pictures
  [ color (makeColorI  30  30  80 255) $ rectangleSolid 800 600
  , color (makeColorI  50  50 120  80) $ translate 0  100 $ rectangleSolid 800 200
  , color (makeColorI  80  60 140  50) $ translate 0  200 $ rectangleSolid 800 100
  ]

-- Stars (static decoration)
drawStars :: Picture
drawStars = color (makeColorI 255 255 255 180) $ pictures
  [ translate x y (circleSolid 1.5) | (x,y) <-
    [ (-350, 250), (-200, 230), (0, 270), (150, 240)
    , (320, 260), (-100, 200), (250, 215), (-280, 280)
    , (380, 235), (-380, 195), (100, 270), (200, 190)
    ]
  ]

drawPlatform :: Platform -> Picture
drawPlatform p =
  translate (platX p) (platY p) $
    pictures
      [ -- main body
        color (makeColorI 80 200 120 255) $
          rectangleSolid (platW p) (platH p)
      , -- top highlight
        translate 0 (platH p/2 - 3) $
          color (makeColorI 140 240 160 255) $
          rectangleSolid (platW p) 4
      , -- bottom shadow
        translate 0 (-(platH p/2) + 2) $
          color (makeColorI 40 120 70 255) $
          rectangleSolid (platW p) 4
      ]

drawCoin :: Coin -> Picture
drawCoin c
  | coinTaken c = blank
  | otherwise =
      translate (coinX c) (coinY c) $
        pictures
          [ color (makeColorI 255 210 50 255) $ circleSolid 10
          , color (makeColorI 255 240 130 200) $ circleSolid 6
          , color (makeColorI 200 160 20 255) $ circle 10
          ]

-- Simple pixel-art style player (blue character with eyes)
drawPlayer :: Float -> Float -> Picture
drawPlayer px py =
  translate px py $
    pictures
      [ -- body
        color (makeColorI 60 110 255 255) $ rectangleSolid playerW playerH
      , -- highlight
        color (makeColorI 120 170 255 180) $
          translate (-5) 6 $ rectangleSolid 8 8
      , -- left eye
        color white $ translate (-6) 6 $ circleSolid 4
      , color (makeColorI 20 20 80 255) $ translate (-6) 6 $ circleSolid 2
      , -- right eye
        color white $ translate 6 6 $ circleSolid 4
      , color (makeColorI 20 20 80 255) $ translate 6 6 $ circleSolid 2
      ]

drawHUD :: Int -> Int -> Picture
drawHUD sc total =
  translate (-370) 260 $
    pictures
      [ color (makeColorI 0 0 0 120) $ rectangleSolid 200 40
      , translate (-90) (-6) $
          scale 0.15 0.15 $
            color (makeColorI 255 210 50 255) $
              text ("Score: " ++ show sc)
      , translate (-90) (-20) $
          scale 0.10 0.10 $
            color (makeColorI 200 220 255 255) $
             text ("Coins: " ++ show (sc `div` 10) ++ "/" ++ "200")
      ]

drawGameOver :: Int -> Picture
drawGameOver sc =
  pictures
    [ color (makeColorI 0 0 0 180) $ rectangleSolid 800 600
    , translate (-160) 40 $
        scale 0.3 0.3 $
          color (makeColorI 255 80 80 255) $
            text "GAME OVER"
    , translate (-130) (-20) $
        scale 0.2 0.2 $
          color white $
            text ("Score: " ++ show sc)
    , translate (-150) (-70) $
        scale 0.12 0.12 $
          color (makeColorI 200 200 200 255) $
            text "You fell into the void!"
    ]

drawWorld :: World -> Picture
drawWorld w =
  let cam = cameraX w
      total = length (coins w)
  in pictures
    [ drawSky
    , drawStars
    , -- everything in world space is offset by -camera
      translate (-cam) 0 $
        pictures
          [ pictures (map drawPlatform (platforms w))
          , pictures (map drawCoin (coins w))
          , drawPlayer (playerX w) (playerY w)
          ]
    , drawHUD (score w) total
    , if gameOver w then drawGameOver (score w) else blank
    ]

-- ============================================================
-- MAIN
-- ============================================================

main :: IO ()
main =
  play
    (InWindow "Haskell Platformer" (800, 600) (100, 100))
    black
    60
    initialWorld
    drawWorld
    handleInput
    updateWorld