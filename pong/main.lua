VIRTUAL_WIDTH = 384
VIRTUAL_HEIGHT = 216
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

PADDLE_WIDTH = 4
PADDLE_HEIGHT = 24
PADDLE_SPEED = 80

BALL_SIZE = 4
AI = 1

LARGE_FONT = love.graphics.newFont(32)
SMALL_FONT = love.graphics.newFont(16)

push = require 'push'

player1 = {
    x = 10, y = 10,
    score = 0
}

player2 = {
    x = VIRTUAL_WIDTH - 18, y = VIRTUAL_HEIGHT - 42,
    score = 0
}

ball = {
    x = VIRTUAL_WIDTH / 2 - BALL_SIZE / 2,
    y = VIRTUAL_HEIGHT / 2 - BALL_SIZE / 2,
    dx = 0, dy = 0
}

gameState = 'title'

function love.load()
    math.randomseed(os.time())
    love.graphics.setDefaultFilter('nearest', 'nearest')
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT)

    resetBall()
end

function love.update(dt)
    if love.keyboard.isDown('up') then
        if player2.y > 0 then
            player2.y = player2.y - PADDLE_SPEED * dt
        end
    elseif love.keyboard.isDown('down') then
        if player2.y < VIRTUAL_HEIGHT - 24 then
            player2.y = player2.y + PADDLE_SPEED * dt
        end
    end   
    
    if gameState == 'play' then 
        ball.x = ball.x + ball.dx * dt
        ball.y = ball.y + ball.dy * dt
        if ball.x <= 0 then
            player2.score = player2.score + 1
            resetBall()
            gameState = 'serve'
        elseif ball.x >= VIRTUAL_WIDTH - BALL_SIZE then
            player1.score = player1.score + 1
            resetBall()
            gameState = 'serve'
        end

        if AI == 1 then
            aiControl(dt)
        end

        if ball.y <= 0 then
            ball.dy = -ball.dy
        elseif ball.y >= VIRTUAL_HEIGHT - BALL_SIZE then
            ball.dy = -ball.dy
        end

        if collides(player1, ball) then
            ball.dx = -ball.dx * 1.05
            ball.x = player1.x + PADDLE_WIDTH
            AI = 0
        elseif collides(player2, ball) then
            ball.dx = -ball.dx * 1.05
            ball.x = player2.x - BALL_SIZE
            AI = 1
        end

        if player1.score == 7 or player2.score == 7 then
            gameState = 'win'
        end

    end
end

function love.keypressed(key)
    if key == 'escape' then
        if gameState == 'play' then
            gameState = 'pause'
        elseif gameState == 'pause' then
            gameState = 'play'
        elseif gameState == 'win' then
            love.event.quit()
        end
    end

    if key == 'y' then
        if gameState == 'pause' then
            love.event.quit()
        end
    end

    if key == 'n' then
        if gameState == 'pause' then
            gameState = 'play'
        end
    end

    if key == 'enter' or key == 'return' then
        if gameState == 'title' then
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'win' then
            gameState = 'title'
            resetScores()
        end
    end
end

function love.draw()
    push:start()
    love.graphics.clear(48/255, 45/255, 52/255, 255/255)

    if gameState == 'title' then
        love.graphics.setFont(LARGE_FONT)
        love.graphics.printf('PONG', 0, VIRTUAL_HEIGHT / 4, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(SMALL_FONT)
        love.graphics.printf('Press Enter', 0, VIRTUAL_HEIGHT - 32, VIRTUAL_WIDTH, 'center')
    end

    if gameState == 'serve' then
        love.graphics.printf('Press enter to serve', 0, VIRTUAL_HEIGHT / 3 , VIRTUAL_WIDTH, 'center')
    end

    if gameState == 'pause' then
        love.graphics.clear(48/255, 45/255, 52/255, 255/255)
        love.graphics.setFont(LARGE_FONT)
        love.graphics.printf('PAUSE', 0, VIRTUAL_HEIGHT / 5, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(SMALL_FONT)
        love.graphics.printf('Quit? y/n', 0, VIRTUAL_HEIGHT / 5 * 3, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press esc to return to game', 0, VIRTUAL_HEIGHT / 5 * 3 + 42, VIRTUAL_WIDTH, 'center')
    end

    love.graphics.setFont(LARGE_FONT)
    love.graphics.print(player1.score, VIRTUAL_WIDTH / 4, 10)
    love.graphics.print(player2.score, VIRTUAL_WIDTH / 4 * 3, 10)
    love.graphics.setFont(SMALL_FONT)

    love.graphics.rectangle('fill', player1.x, player1.y, PADDLE_WIDTH, PADDLE_HEIGHT)
    love.graphics.rectangle('fill', player2.x, player2.y, PADDLE_WIDTH, PADDLE_HEIGHT)
    love.graphics.rectangle('fill', ball.x, ball.y, BALL_SIZE, BALL_SIZE)

    if gameState == 'win' then
        love.graphics.clear(48/255, 45/255, 52/255, 255/255)
        if player1.score == 7 then
            love.graphics.printf('Player 1 wins!', 0 , VIRTUAL_HEIGHT / 2 - 32, VIRTUAL_WIDTH, 'center')
        elseif player2.score == 7 then
            love.graphics.printf('Player 2 wins!', 0 , VIRTUAL_HEIGHT / 2 - 32, VIRTUAL_WIDTH, 'center')
        end  
        love.graphics.printf('Press enter to play again or press esc to quit', 0, VIRTUAL_HEIGHT / 4 * 3, VIRTUAL_WIDTH, 'center')
    end
    push:finish()
end

function collides(p, b)
    return not (p.x > b.x + BALL_SIZE or p.y > b.y + BALL_SIZE or b.x > p.x + PADDLE_WIDTH or b.y > p.y + PADDLE_HEIGHT)
end

function resetBall()
    ball.x = VIRTUAL_WIDTH / 2 - BALL_SIZE / 2
    ball.y = VIRTUAL_HEIGHT / 2 - BALL_SIZE / 2

    ball.dx = 60 + math.random(60)
    if math.random(2) == 1 then
        ball.dx = -ball.dx
    end
    ball.dy = 30 + math.random(60)
    if math.random(2) == 1 then
        ball.dy = -ball.dy
    end
end

function resetScores()
    player1.score = 0
    player2.score = 0
end

function aiControl(dt)
    if player1.y > ball.y then
        player1.y = player1.y - PADDLE_SPEED * dt
    elseif player1.y + PADDLE_HEIGHT + 4 < ball.y then
        if player1.y < VIRTUAL_HEIGHT - 32 then
            player1.y = player1.y + PADDLE_SPEED * dt
        end
    end
end