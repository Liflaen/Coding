import pygame
import random
import math

from pygame import mixer

# initialize pygame
pygame.init()

# create screen window
width = 800
height = 600
screen = pygame.display.set_mode((width,height))

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

# multiplet enemies setup / list
enemyImg = []
enemyX = []
enemyY = []
enemyX_change = []
enemyY_change = []
enemyY_start_change = []
enemyX_speed = []
num_of_enemies = 6
enemy_size = 32

# fillin list of 6 enemies
for i in range(num_of_enemies):
    enemyImg.append(pygame.image.load('images\\ufo-enemy64.png'))
    enemyX.append(random.randint(0, 736))
    enemyY.append(random.randint(-130, -80))
    enemyX_change.append(4)
    enemyX_speed.append(4)
    enemyY_change.append(40)
    enemyY_start_change.append(2)

# final boss setup
final_boss_health = 5
final_boss_healthImg = []
healthX = []
healthY = []
for i in range(final_boss_health):
    final_boss_healthImg.append(pygame.image.load('images\\boss_health32.png'))
    healthX.append(0)
    healthY.append(0)
final_bossImg = pygame.image.load('images\\final_boss128.png')
final_bossX = random.randint(0, 672)
final_bossY = random.randint(-150, -100)
final_boss_start_change = 2
final_bossX_change = 5
final_bossX_speed = 5
final_boss_size = 128

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
score_textX = 10
score_textY = 10

# rest of enemies
rest_in_wave = 6
rest_textX = 10
rest_textY = 31

# general text
font = pygame.font.Font('freesansbold.ttf', 16)

# game over text setup
big_font = pygame.font.Font('freesansbold.ttf', 64)

def main_text(text, x, y):
    main_text = big_font.render(text, True, (255, 255, 255))
    screen.blit(main_text, (x, y))

def show_general_text (x, y, input_text, text):
    # label , True - want to render , Color
    draw_text = font.render("{} : ".format(text) + str(input_text), True, (255, 255, 255))
    screen.blit(draw_text, (x, y))

def player(x, y):
    # blit is basicly draw
    screen.blit(playerImg, (x, y))

def enemy(x, y, i):
    screen.blit(enemyImg[i], (x, y))

def final_boss(x, y):
    screen.blit(final_bossImg, (x, y))

def fire_bullet(x, y):
    global bullet_state
    bullet_state = "fire"
    # +16 and +10 center of ship while firing
    screen.blit(bulletImg, (x + 16, y + 10))

def isCollision(enemyX, enemyY, bulletX, bulletY, size):
    # distance between two points formula
    distance = math.sqrt((math.pow(enemyX - bulletX, 2)) + (math.pow(enemyY - bulletY, 2)))
    if distance < size:
        return True
    else:
        return False
    

# main game loop 
running = True
play_monster_kill = True
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
    for i in range(len(enemyX)):
        # Game over text
        if enemyY[i] > 430:
            for j in range(len(enemyX)):
                enemyY[j] = 2000
            main_text("GAME OVER", 200, 250)
            break
        # a little bit better spawning of enemies coming from shadows generated -130,-80 and then go down until reach Y = 30 , then will start normal beahvior of enemies
        if enemyY[i] <= 30:
            enemyY[i] += enemyY_start_change[i]
        else:
            enemyX[i] += enemyX_change[i]
            if enemyX[i] <= 0:
                enemyY[i] += enemyY_change[i]
                enemyX_change[i] = enemyX_speed[i]
            elif enemyX[i] >= 736:
                enemyY[i] += enemyY_change[i]
                enemyX_change[i] = -enemyX_speed[i]

        # Collision check between enemy and bullet
        collision = isCollision(enemyX[i], enemyY[i], bulletX, bulletY, enemy_size)
        if collision:
            # play sound of enemy explosion
            enemy_explosion = mixer.Sound('sounds\explosion.wav')
            enemy_explosion.play()

            bulletY = bulletY_start_coor
            bullet_state = "ready"
            score_value += 1
            rest_in_wave -= 1
            if score_value < 1: #15
                enemyX[i] = random.randint(0, 736)
                enemyY[i] = random.randint(-130, -80)
            # remove enemy from list
            else:
                enemyX.remove(enemyX[i])
                enemyY.remove(enemyY[i])
                break
        
        enemy(enemyX[i], enemyY[i], i)

    # generate final boss
    if score_value == 6:
        # draw health of final boss
        shift = 5
        heart_size = 32
        for i in range(len(final_boss_healthImg)):
            healthX[i] = width - shift - ((i + 1) * heart_size)
            healthY[i] = shift
            screen.blit(final_boss_healthImg[i], (healthX[i], healthY[i]))
        
        # draw final boss + health
        final_boss(final_bossX, final_bossY)
        
        # final boss monevemnt
        if final_bossY <= 40:
            final_bossY += final_boss_start_change
        else:
            final_bossX += final_bossX_change
            if final_bossX >= 672:
                final_bossX_change -= final_bossX_speed
            elif final_bossX <= 0:
                final_bossX_change += final_bossX_speed

        # collision with boss
        collision = isCollision(final_bossX, final_bossY, bulletX, bulletY, final_boss_size)
        if collision:
            enemy_explosion = mixer.Sound('sounds\explosion.wav')
            enemy_explosion.play()
            bulletY = bulletY_start_coor
            bullet_state = "ready"
            del final_boss_healthImg[-1]

        # if list is empty - no more health do following
        if not final_boss_healthImg:
            final_bossY = 2000
            if play_monster_kill:
                monster_kill = mixer.Sound('sounds\monster_kill.wav')
                monster_kill.play()
                play_monster_kill = False
            main_text("YOU WON", 250, 250)
            
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
    show_general_text(score_textX, score_textY, score_value, "Score")
    show_general_text(rest_textX, rest_textY, rest_in_wave, "Rest in wave")

    # we need update our screen while stuff is changing
    pygame.display.update()