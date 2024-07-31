require 'ruby2d'
require_relative '../ImageHandler' # to read dimemsion of image ==> must install (gem install rmagick)
require_relative '../CollisionChecker'
require_relative '../CommonParameter'
require_relative '../FindingPath/Node'
require_relative '../FindingPath/PathFinder'

include CCHECK



class Monster < Sprite
  attr_reader :x, :y,
              :worldX, :worldY,
              :speed,
              :moveCounter

  attr_accessor :upDirection, :downDirection, :leftDirection, :rightDirection,
                :solidArea,
                :collisionOn,
                :collisionPlayerOn,
                :image,
                :onPath,
                :exist,
                :hitBox,
                :healthBar

  def initialize(worldX, worldY, width, height)

    #1. Image and Animation
    @image = nil

    #2. Health Bar
    @healthBar = nil

    #3. Speed
    @speed = nil

    #3.1. Attack
    @attack = nil

    #4. Direction and Facing
    @upDirection = false
    @downDirection = false
    @leftDirection = false
    @rightDirection = false

    #5. World Coordinate
    @worldX = worldX
    @worldY = worldY

    #6. Solid Area to check collision with other objects
    @solidArea = Rectangle.new(
      x: 8, y: 16,            # Position
      width: 32, height: 32,  # Size
      opacity: 0
    )

    @hitBox = Rectangle.new(
      x: 8 , y: 16,
      width: 32, height: 32,
      opacity: 0.5
    )

    @collisionOn = false
    @collisionPlayerOn = false             #Check if monster collides player

    #7. Existence of monster
    @exist = true


    #8. Attack delay time
    @attackDelay = 0
  end




#-------------------------------- Very Usefull Methods -----------------------------------------
  #1.
  def DrawMonster(player)
    # Screen Coordinate of monster should be
    screenX = @worldX - player.worldX + player.x
    screenY = @worldY - player.worldY + player.y


    hitBox_screenX = @image.x + @solidArea.x 
    hitBox_screenY = @image.y + @solidArea.y

    #World Coordinate of Camera
    cameraWorldX = player.worldX - player.x
    cameraWorldY = player.worldY - player.y

    # Rendering game by removing unnessary images (we keep images in camera's scope, and remove otherwise)
    if(CCHECK.intersect(cameraWorldX, cameraWorldY, CP::SCREEN_WIDTH, CP::SCREEN_HEIGHT,
                        worldX, worldY, CP::TILE_SIZE, CP::TILE_SIZE) == true)  #Notice we want the dimension of camera is exactly same as our window
      @image.x = screenX
      @image.y = screenY
      @image.add

      @hitBox.x = hitBox_screenX
      @hitBox.y = hitBox_screenY
      @hitBox.add
    else
      @image.remove
      @hitBox.remove
    end
  end

  #2.
  def DrawHealthBar(player)
    # Update the health bar
    @healthBar.update()

    # Screen Coordinate of Health Bar should be
    screenX = @worldX - player.worldX + player.x
    screenY = @worldY - player.worldY + player.y - (2/3* CP::TILE_SIZE + 9)

    #World Coordinate of Camera
    cameraWorldX = player.worldX - player.x
    cameraWorldY = player.worldY - player.y

    # Rendering game by removing unnessary images (we keep images in camera's scope, and remove otherwise)
    if(CCHECK.intersect(cameraWorldX, cameraWorldY, CP::SCREEN_WIDTH, CP::SCREEN_HEIGHT,
                        worldX, worldY, CP::TILE_SIZE, CP::TILE_SIZE) == true)  #Notice we want the dimension of camera is exactly same as our window
        @healthBar.heart.x = screenX - 15
        @healthBar.heart.y = screenY
        @healthBar.rec1.x =  screenX
        @healthBar.rec1.y =  screenY
        @healthBar.rec2.x =  @healthBar.rec1.x + 2
        @healthBar.rec2.y =  @healthBar.rec1.y + 2

        # If within the scope of camera, then add health bar to our screen
        @healthBar.heart.add
        @healthBar.rec1.add
        @healthBar.rec2.add
    else # remove otherwise
        @healthBar.heart.remove
        @healthBar.rec1.remove
        @healthBar.rec2.remove
    end
  end

  #3.
  def removeMonster()
    @healthBar.move(-20 * CP::TILE_SIZE,-20 * CP::TILE_SIZE)
    @hitBox.x = -20 * CP::TILE_SIZE
    @hitBox.y = -20 * CP::TILE_SIZE
    @image.x = -20 * CP::TILE_SIZE
    @image.y = -20 * CP::TILE_SIZE
    @wordlX = -20 * CP::TILE_SIZE
    @wordlY = -20 * CP::TILE_SIZE
    @image.remove
  end

  #4.
  def runAnimation
    @image.play animation: :walk
  end

  #5.
  def runAnimationLeft
    @image.play animation: :walk, flip: :horizontal
  end

  #6.
  def stopAnimation
    @image.stop
  end


  #7.
  def checkCollision(player, map, items, npcs, monsters)
    @collisionOn = false

    #1. Check if monster collides any wall
    CCHECK.checkTile(self, map)

    #2. Check if monster collides Player
    if (CCHECK.checkEntity_Collide_SingleTarget(self, player) == true)
      @collisionPlayerOn = true
    else
      @collisionPlayerOn = false
    end
    #3. Check if monster collides any Item in the map
    for i in 0..(items.length - 1)
      CCHECK.checkEntity_Collide_SingleTarget(self, items[i])
    end

    #4. Check if monster collides any NPC in the map
    for i in 0..(npcs.length - 1)
      CCHECK.checkEntity_Collide_SingleTarget(self, npcs[i])
    end

    #5. Check if monster collides any other monsters
    CCHECK.checkMonster_Collide_OtherMonsters(self, monsters)
  end

  #8.
  def beAttacked(ammounts)
    @healthBar.hp -= ammounts
  end

  #9.
  def attackTarget(player)
    if @attackDelay == 30
      player.healthBar.hp -= @attack
      @attackDelay = 0
    else
      @attackDelay += 1
    end
  end
  
end
