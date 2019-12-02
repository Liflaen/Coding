import pygame
import random
import math

from pygame import mixer

# initialize pygame
pygame.init()

# create screen window
screen = pygame.display.set_mode((800,600))

# background screen
background = pygame.image.load('images\\background.png')

# background sound of game (-1 will play it in loop)
mixer.music.load('sounds\\background.wav')
mixer.music.play(-1)

# title and icon of main window
pygame.display.set_caption("Space Invader")
icon = pygame.image.load('images\space-rocket-logo32.png')
pygame.display.set_icon(icon)

# player setup
playerImg = pygame.image.load('images\space-invaders64.png')
playerX = 370
playerY = 480
playerX_change = 0
playerX_speed = 5

# multiplet enemies setup
enemyImg = []
enemyX = []
enemyY = []
enemyX_change = []
enemyY_change = []
enemyX_speed = []
num_of_enemies = 6

for i in range(num_of_enemies):
    enemyImg.append(pygame.image.load('images\\ufo-enemy64.png'))
    enemyX.append(random.randint(0, 736))
    enemyY.append(random.randint(0, 60))
    enemyX_change.append(4)
    enemyY_change.append(40)
    enemyX_speed.append(4)

# bullet setup
# Ready - u cant see bullet
# Fire - bullet is fired and moving
bulletImg = pygame.image.load('images\\bullet32.png')
bulletX = 0
bulletY_start_coor = 480
bulletY = bulletY_start_coor
bulletY_change = 7
bullet_state = "ready"

# Score
score_value = 0
font = pygame.font.Font('freesansbold.ttf', 32)

textX = 10
textY = 10

# game over text setup
game_over_font = pygame.font.Font('freesansbold.ttf', 64)

def game_over_text():
    game_over_text = game_over_font.render("GAME OVER", True, (255, 255, 255))
    screen.blit(game_over_text, (200, 250))

def show_score (x, y):
    # label , True - want to render , Color
    score = font.render("Score : " + str(score_value), True, (255, 255, 255))
    screen.blit(score, (x, y))

def player(x, y):
    # blit is basicly draw
    screen.blit(playerImg, (x, y))

def enemy(x, y, i):
    screen.blit(enemyImg[i], (x, y))

def fire_bullet(x, y):
    global bullet_state
    bullet_state = "fire"
    # +16 and +10 center of ship while firing
    screen.blit(bulletImg, (x + 16, y + 10))

def isCollision(enemyX, enemyY, bulletX, bulletY):
    # distance between two points formula
    distance = math.sqrt((math.pow(enemyX - bulletX, 2)) + (math.pow(enemyY - bulletY, 2)))
    if distance < 32:
        return True
    else:
        return False
    

# main game loop 
running = True
while running:
    # for cycle will search all event in program , it must be there becasue of infinity loop
    for event in pygame.event.get():
        # if close button will be pressed , it will quit program
        if event.type == pygame.QUIT:
            running = False

        # if keystroke is pressed check whether iits right or left
        # any kye pressed
        if event.type == pygame.KEYDOWN:
            if event.key == pygame.K_LEFT:
                playerX_change = -playerX_speed
            if event.key == pygame.K_RIGHT:
                playerX_change = playerX_speed
            if event.key == pygame.K_SPACE:
                # bullet will have same X coor the whole time otherwise with more space X will be changing
                if bullet_state is "ready":
                    bulletX = playerX
                    bullet_sound = mixer.Sound('sounds\laser.wav')
                    bullet_sound.play()
                fire_bullet(bulletX, bulletY)
        # any key released
        if event.type == pygame.KEYUP:
            if event.key == pygame.K_LEFT or event.key == pygame.K_RIGHT:
                playerX_change = 0
                
    # change screen color + boundaries for enemy
    screen.fill((0,0,0))
    screen.blit(background, (0,0))

    # enemy movements
    for i in range(num_of_enemies):
        # Game over text
        if enemyY[i] > 440:
            for j in range(num_of_enemies):
                enemyY[j] = 2000
            game_over_text()
            break

        enemyX[i] += enemyX_change[i]
        if enemyX[i] <= 0:
            enemyY[i] += enemyY_change[i]
            enemyX_change[i] = enemyX_speed[i]
        elif enemyX[i] >= 736:
            enemyY[i] += enemyY_change[i]
            enemyX_change[i] = -enemyX_speed[i]

        # Collision check between enemy and bullet
        collision = isCollision(enemyX[i], enemyY[i], bulletX, bulletY)
        if collision:
            # play sound of enemy explosion
            enemy_explosion = mixer.Sound('sounds\explosion.wav')
            enemy_explosion.play()

            bulletY = bulletY_start_coor
            bullet_state = "ready"
            score_value += 1
            enemyX[i] = random.randint(0, 736)
            enemyY[i] = random.randint(0, 60)
        
        enemy(enemyX[i], enemyY[i], i)

    # add boundaries of spaceshiop + moving space
    playerX += playerX_change
    if playerX <= 0:
        playerX = 0
    elif playerX >= 736:
        playerX = 736    

    # get new shot ready
    if bulletY <= 0:
        bullet_state = "ready"
        bulletY = bulletY_start_coor

    # bullet movement
    if bullet_state is "fire":
        fire_bullet(bulletX, bulletY)
        bulletY -= bulletY_change
    
    player(playerX, playerY)
    show_score(textX, textY)

    # we need update our screen while stuff is changing
    pygame.display.update()