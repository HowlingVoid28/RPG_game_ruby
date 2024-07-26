require 'ruby2d'
require './Character_Class/healthbar'
require_relative '../ImageHandler' # to read dimemsion of image ==> must install (gem install rmagick)
require_relative '../CollisionChecker'
require_relative '../CommonParameter'
include CCHECK




class Player < Sprite
  attr_reader :x, :y, :speed, :worldX, :worldY
  attr_accessor :upDirection, :downDirection, :leftDirection, :rightDirection, :solidArea, :collisionOn


  def initialize(worldX, worldY, width, height)
    @first_frame = { x: 248 , y: 0, width: 48, height: 50, time: 80, flip: :none }
    super(
      'Image/Warrior_Red.png',
      x: CP::SCREEN_WIDTH / 2 - (CP::TILE_SIZE/2),
      y: CP::SCREEN_HEIGHT / 2 - (CP::TILE_SIZE/2),
      width: width, height: height,
      clip_x: @first_frame[:x], clip_y: @first_frame[:y],
      clip_width: @first_frame[:width], clip_height: @first_frame[:height],
      animations: {
       walk:
       [
          @first_frame,
          {
            x: 5, y: 0,
            width: 43, height: 50,
            time: 80, flip: :none
          },
          {
            x: 45, y: 0,
            width: 45, height: 50,
            time: 80, flip: :none
          },
          {
            x: 136, y: 0,
            width: 56, height: 50,
            time: 80, flip: :none
          },
          {
            x: 192, y: 0,
            width: 56, height: 50,
            time: 80, flip: :none
          }
        ]

      }
    )

    #health bar
    @healthbar = Healthbar.new(
      200,
      200,
      CP::SCREEN_WIDTH / 2 - (CP::TILE_SIZE/2) - (width*2/3),
      CP::SCREEN_HEIGHT / 2 - (CP::TILE_SIZE/2) - 10,
      100
    )


    @speed = 3
    #@direction = nil
    @upDirection = false
    @downDirection = false
    @leftDirection = false
    @rightDirection = false

    #
    @worldX = worldX
    @worldY = worldY

    #Area for collision
    @solidArea = Rectangle.new(
      x: 8, y: 16,            # Position
      width: 32, height: 32,  # Size
      opacity: 0
    )

    @collisionOn = false


  end


#-------------------------------- Update -----------------------------------------
  def updatePlayer(monsters, map)


    @collisionOn = false
    #1. Check if player collides wall
    CCHECK.checkTile(self, map)

    #2. Check if player collides any monster
    monsterIndex = CCHECK.checkEntity_Collide_AllTargets(self, monsters)

    if(monsterIndex != -1)
      puts 'You are hitting a monster'
    end


    if(@collisionOn == false)
      if(self.upDirection == true)
        @worldY -= @speed
      end
      if(self.downDirection == true)
        @worldY += @speed
      end
      if(self.leftDirection == true)
        @worldX -= @speed
      end
      if(self.rightDirection == true)
        @worldX += @speed
      end
    end

  end


#-------------------------------- Move -----------------------------------------
  def move()

  end

#-------------------------------- Setter Methods -----------------------------------------

  def runAnimation()
    if @leftDirection
      self.play animation: :walk , loop: true, flip: :horizontal
    else
      self.play(animation: :walk)
    end
  end

#-------------------------------- Stop Moving -----------------------------------------

  def stop()
    @first_frame
    super
  end
end


# player = Player.new(48, 48)
# #Setting Window
# set width: SCREEN_HEIGHT
# set height: SCREEN_WIDTH
# set title: "20x20 Grid RPG"
# set resizable: true
# #set fullscreen: true
# show
