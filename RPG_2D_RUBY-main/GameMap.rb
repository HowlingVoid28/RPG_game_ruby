require 'ruby2d'
require_relative 'Terrain_Class/Fire'
require_relative 'Terrain_Class/Wall'
require_relative 'Terrain_Class/Water'
require_relative 'Terrain_Class/Grass'
require_relative 'CollisionChecker'
require_relative 'CommonParameter'
require_relative 'ImageHandler'
require_relative 'Get_map'
include CCHECK

#Wall: 0
#Grass: 1
#Water: 2
#Fire: 3

class GameMap
    #
    attr_reader :tileManager, :tileSet, :tile
    def initialize()
        @tile = [
                 Wall.new(0, 0, CP::TILE_SIZE, CP::TILE_SIZE),
                 Grass.new(0, 0, CP::TILE_SIZE, CP::TILE_SIZE),
                 Water.new(0, 0, CP::TILE_SIZE, CP::TILE_SIZE),
                 Fire.new(0, 0, CP::TILE_SIZE, CP::TILE_SIZE)
                ]
        for i in 0..(@tile.length)-1
            @tile[i].image.remove
        end

        # Read map from file
        @tileManager = get_Map('Map/map1.txt')

        # Create a 2D array with all elements initialized to nil
        @tileSet = Array.new(CP::MAX_WORLD_ROWS) {Array.new(CP::MAX_WORLD_COLS, nil)}

        #showMap
        self.showMap()
    end

    #
    def showMap()
        for i in 0..CP::MAX_WORLD_ROWS-1
            for j in 0..CP::MAX_WORLD_COLS-1
                case @tileManager[i][j]
                    when  0
                        @tileSet[i][j] = Wall.new(j*CP::TILE_SIZE, i*CP::TILE_SIZE, CP::TILE_SIZE, CP::TILE_SIZE)
                    when  1
                        @tileSet[i][j] = Grass.new(j*CP::TILE_SIZE, i*CP::TILE_SIZE, CP::TILE_SIZE, CP::TILE_SIZE)
                    when  2
                        @tileSet[i][j] = Water.new(j*CP::TILE_SIZE, i*CP::TILE_SIZE, CP::TILE_SIZE, CP::TILE_SIZE)
                    when  3
                        @tileSet[i][j] = Fire.new(j*CP::TILE_SIZE, i*CP::TILE_SIZE, CP::TILE_SIZE, CP::TILE_SIZE)
                end
            end
        end
    end


    #
    def camera(player)
        for i in 0..CP::MAX_WORLD_ROWS-1
            for j in 0..CP::MAX_WORLD_COLS-1
                worldX = j * CP::TILE_SIZE
                worldY = i * CP::TILE_SIZE
                screenX = worldX - player.worldX + player.x
                screenY = worldY - player.worldY + player.y

                # #World Coordinate of Camera
                # cameraX = player.worldX - player.x
                # cameraY = player.worldY - player.y
                
                
                # if(CCHECK.intersect(worldX, worldY, CP::TILE_SIZE, CP::TILE_SIZE, 
                #                     cameraX, cameraY, CP::SCREEN_WIDTH, CP::SCREEN_HEIGHT) == true)  #Notice we want the dimension of camera is exactly same as our window
                #      @tileSet[i][j].image.x = screenX
                #      @tileSet[i][j].image.y = screenY

                #       puts "#{i}  #{j}  \n"
                # end

                # if ( worldX + 1*CP::TILE_SIZE > player.worldX - player.x &&
                #      worldX - 1*CP::TILE_SIZE < player.worldX + player.x &&
                #      worldY + 1*CP::TILE_SIZE > player.worldY - player.y &&
                #      worldY - 1*CP::TILE_SIZE < player.worldY + player.y)

                     @tileSet[i][j].image.x = screenX
                     @tileSet[i][j].image.y = screenY 

                #      puts "#{i}  #{j}  \n"
                # end
                #puts "#{i}  #{j}  \n"
            end
        end
    end

    
    #
    def update(player)
        self.camera(player)
    end
end





# #Testing
# map = GameMap.new()
# #------------------------------------------------------- Set up window ---------------------------------------
# #Setting Window
# set width: CP::SCREEN_HEIGHT
# set height: CP::SCREEN_WIDTH
# set title: "20x20 Grid RPG"
# set resizable: true
# #set fullscreen: true


# #------------------------------------------------------- Show window ---------------------------------------
# show
