//
//  LavaShooterGame.swift
//  DF723
//
//  Created by IGOR on 22/10/2025.
//

import SwiftUI
import Combine

// MARK: - Game Models

struct Enemy: Identifiable {
    let id = UUID()
    var position: CGPoint
    var velocity: CGFloat
    var size: CGFloat
    var type: EnemyType
    
    enum EnemyType: CaseIterable {
        case coin, diamond, meteor, bomb
        
        var icon: String {
            switch self {
            case .coin: return "dollarsign.circle.fill"
            case .diamond: return "diamond.fill"
            case .meteor: return "flame.fill"
            case .bomb: return "exclamationmark.triangle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .coin: return LavaTheme.accent
            case .diamond: return Color.cyan
            case .meteor: return LavaTheme.primaryButton
            case .bomb: return Color.purple
            }
        }
        
        var description: String {
            switch self {
            case .coin: return "Collect for +10 points"
            case .diamond: return "Collect for +50 points"
            case .meteor: return "Destroy or lose life!"
            case .bomb: return "Destroy or lose life!"
            }
        }
    }
}

struct Bullet: Identifiable {
    let id = UUID()
    var position: CGPoint
}

// MARK: - Game View

struct LavaShooterGameView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var game = GameState()
    
    var body: some View {
        ZStack {
            // Background
            LavaTheme.backgroundGradient
                .ignoresSafeArea()
            
            // Game Area
            GeometryReader { geometry in
                ZStack {
                    // Enemies
                    ForEach(game.enemies) { enemy in
                        Image(systemName: enemy.type.icon)
                            .font(.system(size: enemy.size))
                            .foregroundColor(enemy.type.color)
                            .position(enemy.position)
                            .shadow(color: enemy.type.color, radius: 10)
                    }
                    
                    // Bullets
                    ForEach(game.bullets) { bullet in
                        Circle()
                            .fill(LavaTheme.accent)
                            .frame(width: 8, height: 8)
                            .position(bullet.position)
                            .shadow(color: LavaTheme.accent, radius: 5)
                    }
                    
                    // Player
                    VStack {
                        Spacer()
                        
                        Image(systemName: "scope")
                            .font(.system(size: 40))
                            .foregroundColor(LavaTheme.accent)
                            .position(x: game.playerX, y: geometry.size.height - 60)
                            .shadow(color: LavaTheme.accent, radius: 15)
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            game.updatePlayerPosition(x: value.location.x, in: geometry.size)
                        }
                )
                .simultaneousGesture(
                    TapGesture()
                        .onEnded { _ in
                            game.shoot(from: geometry.size)
                        }
                )
            }
            
            // UI Overlay
            VStack {
                // Top Bar
                HStack {
                    // Score
                    HStack(spacing: 8) {
                        Image(systemName: "star.fill")
                            .foregroundColor(LavaTheme.accent)
                        Text("\(game.score)")
                            .font(LavaTheme.headlineFont)
                            .foregroundColor(LavaTheme.text)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(LavaTheme.cardBackground)
                    )
                    
                    Spacer()
                    
                    // Lives with debug
                    HStack(spacing: 4) {
                        ForEach(0..<max(0, game.lives), id: \.self) { _ in
                            Image(systemName: "heart.fill")
                                .foregroundColor(LavaTheme.primaryButton)
                        }
                        // Show count for debugging
                        Text("(\(game.lives))")
                            .font(.caption)
                            .foregroundColor(LavaTheme.text.opacity(0.7))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(LavaTheme.cardBackground)
                    )
                    
                    Spacer()
                    
                    // Close button
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(LavaTheme.text.opacity(0.6))
                    }
                }
                .padding()
                
                Spacer()
                
                // Instructions
                if !game.gameStarted {
                    VStack(spacing: 16) {
                        Text("Lava Shooter")
                            .font(LavaTheme.titleFont)
                            .foregroundColor(LavaTheme.text)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "hand.tap.fill")
                                    .foregroundColor(LavaTheme.accent)
                                Text("Tap to shoot")
                                    .font(LavaTheme.bodyFont)
                                    .foregroundColor(LavaTheme.text)
                            }
                            
                            HStack {
                                Image(systemName: "hand.point.left.fill")
                                    .foregroundColor(LavaTheme.accent)
                                Text("Drag to move")
                                    .font(LavaTheme.bodyFont)
                                    .foregroundColor(LavaTheme.text)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(LavaTheme.cardBackground)
                        )
                        
                        Button(action: { game.startGame() }) {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Start Game")
                            }
                        }
                        .buttonStyle(LavaButtonStyle())
                    }
                    .padding()
                }
                
                // Game Over
                if game.gameOver {
                    VStack(spacing: 16) {
                        Text("Game Over!")
                            .font(LavaTheme.titleFont)
                            .foregroundColor(LavaTheme.primaryButton)
                        
                        Text("Score: \(game.score)")
                            .font(LavaTheme.headlineFont)
                            .foregroundColor(LavaTheme.text)
                        
                        Button(action: { game.restart() }) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("Play Again")
                            }
                        }
                        .buttonStyle(LavaButtonStyle())
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(LavaTheme.cardBackground)
                    )
                    .padding()
                }
            }
        }
        .onAppear {
            game.setup()
        }
    }
}

// MARK: - Game State

class GameState: ObservableObject {
    @Published var enemies: [Enemy] = []
    @Published var bullets: [Bullet] = []
    @Published var playerX: CGFloat = 200
    @Published var score: Int = 0
    @Published var lives: Int = 3
    @Published var gameStarted: Bool = false
    @Published var gameOver: Bool = false
    
    private var screenSize: CGSize = .zero
    private var timer: Timer?
    private var spawnTimer: Timer?
    
    func setup() {
        // Game will start when user presses play
    }
    
    func startGame() {
        gameStarted = true
        gameOver = false
        score = 0
        lives = 3
        enemies = []
        bullets = []
        
        // Main game loop
        timer = Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true) { [weak self] _ in
            self?.update()
        }
        
        // Spawn enemies
        spawnTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.spawnEnemy()
        }
    }
    
    func restart() {
        startGame()
    }
    
    func updatePlayerPosition(x: CGFloat, in size: CGSize) {
        screenSize = size
        playerX = min(max(x, 40), size.width - 40)
    }
    
    func shoot(from size: CGSize) {
        guard gameStarted && !gameOver else { return }
        screenSize = size
        
        let bullet = Bullet(position: CGPoint(x: playerX, y: size.height - 80))
        bullets.append(bullet)
    }
    
    private func spawnEnemy() {
        guard gameStarted && !gameOver else { return }
        guard screenSize != .zero else { return }
        
        let type = Enemy.EnemyType.allCases.randomElement()!
        let x = CGFloat.random(in: 40...(screenSize.width - 40))
        let size = CGFloat.random(in: 30...50)
        let velocity = CGFloat.random(in: 2...5)
        
        let enemy = Enemy(
            position: CGPoint(x: x, y: -50),
            velocity: velocity,
            size: size,
            type: type
        )
        
        enemies.append(enemy)
    }
    
    private func update() {
        guard screenSize != .zero else { return }
        
        // Move enemies down
        for i in enemies.indices {
            enemies[i].position.y += enemies[i].velocity
        }
        
        // Move bullets up
        for i in bullets.indices {
            bullets[i].position.y -= 10
        }
        
        // Check collisions first
        checkCollisions()
        
        // Check if bad enemies reached bottom and remove them immediately
        // Count how many bad enemies reached bottom this frame
        var livesLost = 0
        
        enemies.removeAll { enemy in
            if enemy.position.y > screenSize.height {
                // Enemy is past the bottom line
                if enemy.type == .meteor || enemy.type == .bomb {
                    // Bad enemy reached bottom - lose a life
                    livesLost += 1
                    print("⚠️ \(enemy.type) reached bottom!")
                }
                return true // Remove this enemy
            }
            return false // Keep this enemy
        }
        
        // Apply life loss
        if livesLost > 0 {
            lives -= livesLost
            print("💔 Lost \(livesLost) lives. Remaining: \(lives)")
        }
        
        // Remove off-screen bullets
        bullets.removeAll { $0.position.y < -50 }
        
        // Check game over AFTER all updates
        if lives <= 0 {
            print("💀 Game Over! Final lives: \(lives)")
            endGame()
        }
    }
    
    private func checkCollisions() {
        var bulletsToRemove: Set<UUID> = []
        var enemiesToRemove: Set<UUID> = []
        
        for bullet in bullets {
            for enemy in enemies {
                let distance = sqrt(
                    pow(bullet.position.x - enemy.position.x, 2) +
                    pow(bullet.position.y - enemy.position.y, 2)
                )
                
                if distance < enemy.size / 2 {
                    bulletsToRemove.insert(bullet.id)
                    enemiesToRemove.insert(enemy.id)
                    
                    // Update score based on enemy type
                    // Good objects give positive points, bad objects give negative
                    // But NO life loss when shooting - only when they reach bottom
                    switch enemy.type {
                    case .coin:
                        score += 10
                    case .diamond:
                        score += 50
                    case .meteor:
                        // Successfully destroyed meteor - just remove it, no penalty
                        score += 5  // Small bonus for destroying danger
                    case .bomb:
                        // Successfully destroyed bomb - just remove it, no penalty
                        score += 10  // Bonus for destroying bomb
                    }
                }
            }
        }
        
        bullets.removeAll { bulletsToRemove.contains($0.id) }
        enemies.removeAll { enemiesToRemove.contains($0.id) }
    }
    
    private func endGame() {
        gameOver = true
        gameStarted = false
        timer?.invalidate()
        spawnTimer?.invalidate()
        timer = nil
        spawnTimer = nil
    }
    
    deinit {
        timer?.invalidate()
        spawnTimer?.invalidate()
    }
}

#Preview {
    LavaShooterGameView()
}

