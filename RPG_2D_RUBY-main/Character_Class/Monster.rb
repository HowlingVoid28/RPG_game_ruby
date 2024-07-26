require 'ruby2d'
require_relative '../ImageHandler' # to read dimemsion of image ==> must install (gem install rmagick)
require_relative '../CollisionChecker'
require_relative '../CommonParameter'
require_relative '../FindingPath/Node'
require_relative '../FindingPath/PathFinder'

include CCHECK



class Monster < Sprite
  attr_reader :x, :y, :speed, :worldX, :worldY, :moveCounter
  attr_accessor :upDirection, :downDirection, :leftDirection, :rightDirection, :solidArea, :collisionOn, :image, :onPath

  def initialize(worldX, worldY, width, height)

    @image = nil

    #Direction and Speed
    @speed = nil
    @upDirection = false
    @downDirection = false
    @leftDirection = false
    @rightDirection = false

    #World Coordinate
    @worldX = worldX
    @worldY = worldY

    #Area for collision
    @solidArea = Rectangle.new(
      x: 8, y: 16,            # Position
      width: 32, height: 32,  # Size
      opacity: 0
    )
    @collisionOn = false

    #This will be convenient for move function
    @moveCounter = 0

    #This is used to find the shortest path
    @onPath = false
  end




#-------------------------------- Very Usefull Methods -----------------------------------------
  #
  def DrawMonster(player)
    #Where to draw monster in the screen (window)
    screenX = @worldX - player.worldX + player.x
    screenY = @worldY - player.worldY + player.y
    # if (@worldX + 3*CP::TILE_SIZE >= player.worldX - player.x &&
    #     @worldX - 3*CP::TILE_SIZE <= player.worldX + player.x &&
    #     @worldY + 3*CP::TILE_SIZE >= player.worldY - player.y &&
    #     @worldY - 3*CP::TILE_SIZE <= player.worldY + player.y)

        @image.x = screenX
        @image.y = screenY
    # end
  end


  #
  def checkCollision(player, map)
    #1. Check if monster collides wall
    CCHECK.checkTile(self, map)
    #2. Check if monster collides Player
    CCHECK.checkEntity_Collide_SingleTarget(self, player)
  end

#------------------------------ Random Move ---------------------------------------------------
  def randMove(player, map)

    @moveCounter = @moveCounter + 1
    #puts "#{@moveCounter} \n"
    if(@moveCounter == 20)
      @upDirection = false
      @downDirection = false
      @leftDirection = false
      @rightDirection = false

      ranNum = rand(1..100)
      if(1 <= ranNum && ranNum <= 25)
        @upDirection = true
      elsif(25 < ranNum && ranNum <= 50)
        @downDirection = true
      elsif(50 < ranNum && ranNum <= 75)
        @leftDirection = true
      else
        @rightDirection = true
      end


      # Checking collision before moving
      @collisionOn = false
      self.checkCollision(player, map)

      if(@collisionOn == false)
        if(self.upDirection == true)
          @worldY -= @speed
        elsif(self.downDirection == true)
          @worldY += @speed
        elsif(self.leftDirection == true)
          @worldX -= @speed
        elsif(self.rightDirection == true)
          @worldX += @speed
        end
      end
    @moveCounter = 0 #reset moveCounter
    end
  end


  #
  def moveForwardTo(goalRow, goalCol, player, map, pFinder)

    self.searchPath(goalRow, goalCol, player, map, pFinder)

    if(@onPath == true)

      if(self.upDirection == true)
        @worldY -= @speed
      elsif(self.downDirection == true)
        @worldY += @speed
      elsif(self.leftDirection == true)
        @worldX -= @speed
      elsif(self.rightDirection == true)
        @worldX += @speed
      end
    else
      self.randMove(player,map)
    end

    #Reset node
    pFinder.resetNodes
  end


  #
  def searchPath(goalRow, goalCol, player, map, pFinder)
    startRow = (@worldY + @solidArea.y) / CP::TILE_SIZE
    startCol = (@worldX + @solidArea.x) / CP::TILE_SIZE

    pFinder.setNodes(startRow, startCol, goalRow, goalCol, map)

    if (pFinder.search() == true)
      @onPath = true

      # next worldX and worldY
      nextX = pFinder.pathList[0].row * CP::TILE_SIZE
      nextY = pFinder.pathList[0].col * CP::TILE_SIZE

      # Entity's solid area
      enLeftX  = @worldX + @solidArea.x
      enRightX = @worldX + @solidArea.x + @solidArea.width
      enTopY   = @worldY + @solidArea.y 
      enBottomY   = @worldY + @solidArea.y + @solidArea.height


      if(enTopY > nextY && enLeftX >= nextX && enRightX < nextX + CP::TILE_SIZE)
        @upDirection = true
      elsif(enTopY < nextY && enLeftX >= nextX && enRightX < nextX + CP::TILE_SIZE)
        @downDirection = true
      elsif(enTopY >= nextY && enBottomY < nextY + CP::TILE_SIZE)
        # should go left or go right ?
        if(enLeftX > nextX)
          @leftDirection = true
        end
        if(enLeftX < nextX)
          @rightDirection = true
        end
      elsif(enTopY > nextY && enLeftX > nextX)
        # should go up or go left ?
        @upDirection = true                     # <<<<<<------------------------------------------- carefull
        self.checkCollision(player, map)
        if(@collisionOn == true)
          @leftDirection = true
          @upDirection = false
        end
      elsif(enTopY > nextY && enLeftX < nextX)
        # should go up or go right ?
        @upDirection = true                     # <<<<<<------------------------------------------- carefull
        self.checkCollision(player, map)
        if(@collisionOn == true)
          @rightDirection = true
          @upDirection = false
        end
      elsif(enTopY < nextY && enLeftX > nextX)
        # should go down or go left ?
        @downDirection = true                   # <<<<<<------------------------------------------- carefull
        self.checkCollision(player, map)
        if(@collisionOn == true)
          @leftDirection = true
          @downDirection = false
        end
      elsif(enTopY < nextY && enLeftX < nextX)
        # should go down or go right ?
        @downDirection = true                   # <<<<<<------------------------------------------- carefull
        self.checkCollision(player, map)
        if(@collisionOn == true)
          @rightDirection = true
          @downDirection = false
        end
      end

      # Stop when catching the goal
      nextRow = pFinder.pathList[0].row
      nextCol = pFinder.pathList[0].col
      if(nextRow == goalRow && nextCol == goalCol)
        @onPath = false
      end
    end
  end

end
