//
//  GoalsView.swift
//  DF723
//
//  Created by IGOR on 22/10/2025.
//

import SwiftUI

struct GoalsView: View {
    @StateObject private var dataManager = DataManager.shared
    @State private var showAddGoal = false
    @State private var selectedGoal: SavingGoal?
    @State private var animate = false
    
    var body: some View {
        ZStack {
            LavaTheme.backgroundGradient
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: LavaTheme.paddingLarge) {
                    // Header
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Your Goals")
                                .font(LavaTheme.titleFont)
                                .foregroundColor(LavaTheme.text)
                            Text("\(dataManager.goals.count) active goals")
                                .font(LavaTheme.captionFont)
                                .foregroundColor(LavaTheme.text.opacity(0.6))
                        }
                        Spacer()
                        Button(action: { showAddGoal = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(LavaTheme.accent)
                        }
                    }
                    .padding(.horizontal, LavaTheme.paddingLarge)
                    .padding(.top, LavaTheme.paddingLarge)
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : -20)
                    
                    if dataManager.goals.isEmpty {
                        EmptyGoalsView(showAddGoal: $showAddGoal)
                            .padding(.top, 60)
                            .opacity(animate ? 1 : 0)
                    } else {
                        ForEach(Array(dataManager.goals.enumerated()), id: \.element.id) { index, goal in
                            GoalCard(goal: goal, onTap: { selectedGoal = goal })
                                .padding(.horizontal, LavaTheme.paddingLarge)
                                .opacity(animate ? 1 : 0)
                                .offset(y: animate ? 0 : -20)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.1), value: animate)
                        }
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding(.bottom, LavaTheme.paddingLarge)
            }
        }
        .sheet(isPresented: $showAddGoal) {
            AddGoalSheet(isPresented: $showAddGoal)
        }
        .sheet(item: $selectedGoal) { goal in
            GoalDetailSheet(goal: binding(for: goal)) {
                selectedGoal = nil
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                animate = true
            }
        }
    }
    
    private func binding(for goal: SavingGoal) -> Binding<SavingGoal> {
        guard let index = dataManager.goals.firstIndex(where: { $0.id == goal.id }) else {
            return .constant(goal)
        }
        return $dataManager.goals[index]
    }
}

struct EmptyGoalsView: View {
    @Binding var showAddGoal: Bool
    
    var body: some View {
        VStack(spacing: LavaTheme.paddingLarge) {
            ZStack {
                Circle()
                    .fill(LavaTheme.lavaGlow)
                    .frame(width: 100, height: 100)
                    .blur(radius: 30)
                    .opacity(0.4)
                
                Image(systemName: "target")
                    .font(.system(size: 50))
                    .foregroundColor(LavaTheme.text.opacity(0.6))
            }
            
            VStack(spacing: LavaTheme.paddingSmall) {
                Text("No goals yet")
                    .font(LavaTheme.headlineFont)
                    .foregroundColor(LavaTheme.text)
                
                Text("Create your first savings goal\nand start your journey")
                    .font(LavaTheme.bodyFont)
                    .foregroundColor(LavaTheme.text.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
            
            Button(action: { showAddGoal = true }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Goal")
                }
            }
            .buttonStyle(LavaButtonStyle())
        }
        .padding(LavaTheme.paddingXLarge)
    }
}

struct GoalCard: View {
    let goal: SavingGoal
    let onTap: () -> Void
    @State private var glowAnimate = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: LavaTheme.paddingMedium) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(goal.title)
                            .font(LavaTheme.headlineFont)
                            .foregroundColor(LavaTheme.text)
                        
                        Text(goal.motivationalMessage)
                            .font(LavaTheme.smallFont)
                            .foregroundColor(goal.isCompleted ? LavaTheme.accent : LavaTheme.text.opacity(0.6))
                    }
                    
                    Spacer()
                    
                    if goal.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(LavaTheme.accent)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(formatCurrency(goal.currentAmount))
                            .font(LavaTheme.bodyFont.weight(.semibold))
                            .foregroundColor(LavaTheme.text)
                        
                        Spacer()
                        
                        Text(formatCurrency(goal.targetAmount))
                            .font(LavaTheme.bodyFont)
                            .foregroundColor(LavaTheme.text.opacity(0.6))
                    }
                    
                    GlowingProgressBar(progress: goal.progress, height: 8)
                    
                    Text("\(Int(goal.progress * 100))% complete")
                        .font(LavaTheme.smallFont)
                        .foregroundColor(LavaTheme.accent)
                }
            }
            .padding(LavaTheme.paddingLarge)
            .lavaCard()
            .overlay(
                RoundedRectangle(cornerRadius: LavaTheme.cornerRadiusMedium)
                    .stroke(goal.isCompleted ? LavaTheme.accent : Color.clear, lineWidth: 2)
                    .opacity(goal.isCompleted && glowAnimate ? 0.6 : 0)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            if goal.isCompleted {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    glowAnimate = true
                }
            }
        }
    }
}

struct AddGoalSheet: View {
    @Binding var isPresented: Bool
    @StateObject private var dataManager = DataManager.shared
    @State private var title = ""
    @State private var targetAmount = ""
    
    var body: some View {
        ZStack {
            LavaTheme.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: LavaTheme.paddingLarge) {
                HStack {
                    Text("New Goal")
                        .font(LavaTheme.titleFont)
                        .foregroundColor(LavaTheme.text)
                    Spacer()
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(LavaTheme.text.opacity(0.6))
                    }
                }
                .padding(.horizontal, LavaTheme.paddingLarge)
                .padding(.top, LavaTheme.paddingLarge)
                
                VStack(alignment: .leading, spacing: LavaTheme.paddingMedium) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Goal Title")
                            .font(LavaTheme.captionFont)
                            .foregroundColor(LavaTheme.text.opacity(0.7))
                        
                        TextField("e.g., New Car, Vacation", text: $title)
                            .font(LavaTheme.bodyFont)
                            .foregroundColor(LavaTheme.text)
                            .padding(LavaTheme.paddingMedium)
                            .background(
                                RoundedRectangle(cornerRadius: LavaTheme.cornerRadiusSmall)
                                    .fill(LavaTheme.cardBackground)
                            )
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Target Amount")
                            .font(LavaTheme.captionFont)
                            .foregroundColor(LavaTheme.text.opacity(0.7))
                        
                        TextField("0.00", text: $targetAmount)
                            .keyboardType(.decimalPad)
                            .font(LavaTheme.bodyFont)
                            .foregroundColor(LavaTheme.text)
                            .padding(LavaTheme.paddingMedium)
                            .background(
                                RoundedRectangle(cornerRadius: LavaTheme.cornerRadiusSmall)
                                    .fill(LavaTheme.cardBackground)
                            )
                    }
                }
                .padding(.horizontal, LavaTheme.paddingLarge)
                
                Spacer()
                
                Button(action: {
                    if !title.isEmpty, let amount = Double(targetAmount), amount > 0 {
                        dataManager.addGoal(title: title, targetAmount: amount)
                        isPresented = false
                    }
                }) {
                    Text("Create Goal")
                }
                .buttonStyle(LavaButtonStyle())
                .disabled(title.isEmpty || targetAmount.isEmpty || Double(targetAmount) == nil || Double(targetAmount)! <= 0)
                .opacity((title.isEmpty || targetAmount.isEmpty || Double(targetAmount) == nil || Double(targetAmount)! <= 0) ? 0.5 : 1.0)
                .padding(.horizontal, LavaTheme.paddingLarge)
                .padding(.bottom, LavaTheme.paddingLarge)
            }
        }
    }
}

struct GoalDetailSheet: View {
    @Binding var goal: SavingGoal
    let onDismiss: () -> Void
    @StateObject private var dataManager = DataManager.shared
    @State private var contributionAmount = ""
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        ZStack {
            LavaTheme.backgroundGradient
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: LavaTheme.paddingLarge) {
                    HStack {
                        Text("Goal Details")
                            .font(LavaTheme.titleFont)
                            .foregroundColor(LavaTheme.text)
                        Spacer()
                        Button(action: { onDismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(LavaTheme.text.opacity(0.6))
                        }
                    }
                    .padding(.horizontal, LavaTheme.paddingLarge)
                    .padding(.top, LavaTheme.paddingLarge)
                    
                    // Goal Info Card
                    VStack(alignment: .leading, spacing: LavaTheme.paddingMedium) {
                        HStack {
                            Text(goal.title)
                                .font(LavaTheme.headlineFont)
                                .foregroundColor(LavaTheme.text)
                            Spacer()
                            if goal.isCompleted {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(LavaTheme.accent)
                            }
                        }
                        
                        Divider()
                            .background(LavaTheme.highlight.opacity(0.3))
                        
                        VStack(spacing: LavaTheme.paddingSmall) {
                            HStack {
                                Text("Current Amount")
                                    .font(LavaTheme.bodyFont)
                                    .foregroundColor(LavaTheme.text.opacity(0.7))
                                Spacer()
                                Text(formatCurrency(goal.currentAmount))
                                    .font(LavaTheme.bodyFont.weight(.semibold))
                                    .foregroundColor(LavaTheme.accent)
                            }
                            
                            HStack {
                                Text("Target Amount")
                                    .font(LavaTheme.bodyFont)
                                    .foregroundColor(LavaTheme.text.opacity(0.7))
                                Spacer()
                                Text(formatCurrency(goal.targetAmount))
                                    .font(LavaTheme.bodyFont.weight(.semibold))
                                    .foregroundColor(LavaTheme.text)
                            }
                            
                            HStack {
                                Text("Remaining")
                                    .font(LavaTheme.bodyFont)
                                    .foregroundColor(LavaTheme.text.opacity(0.7))
                                Spacer()
                                Text(formatCurrency(max(goal.targetAmount - goal.currentAmount, 0)))
                                    .font(LavaTheme.bodyFont.weight(.semibold))
                                    .foregroundColor(LavaTheme.primaryButton)
                            }
                        }
                        
                        GlowingProgressBar(progress: goal.progress, height: 10)
                            .padding(.top, 8)
                        
                        Text(goal.motivationalMessage)
                            .font(LavaTheme.captionFont)
                            .foregroundColor(LavaTheme.accent)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 4)
                    }
                    .padding(LavaTheme.paddingLarge)
                    .lavaCard()
                    .padding(.horizontal, LavaTheme.paddingLarge)
                    
                    // Add Contribution
                    if !goal.isCompleted {
                        VStack(alignment: .leading, spacing: LavaTheme.paddingMedium) {
                            Text("Add Contribution")
                                .font(LavaTheme.headlineFont)
                                .foregroundColor(LavaTheme.text)
                            
                            TextField("Enter amount", text: $contributionAmount)
                                .keyboardType(.decimalPad)
                                .font(LavaTheme.bodyFont)
                                .foregroundColor(LavaTheme.text)
                                .padding(LavaTheme.paddingMedium)
                                .background(
                                    RoundedRectangle(cornerRadius: LavaTheme.cornerRadiusSmall)
                                        .fill(LavaTheme.cardBackground)
                                )
                            
                            Button(action: {
                                if let amount = Double(contributionAmount), amount > 0 {
                                    dataManager.updateGoalProgress(goalId: goal.id, amount: amount)
                                    contributionAmount = ""
                                }
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add to Goal")
                                }
                            }
                            .buttonStyle(LavaButtonStyle())
                            .disabled(contributionAmount.isEmpty || Double(contributionAmount) == nil || Double(contributionAmount)! <= 0)
                            .opacity((contributionAmount.isEmpty || Double(contributionAmount) == nil || Double(contributionAmount)! <= 0) ? 0.5 : 1.0)
                        }
                        .padding(LavaTheme.paddingLarge)
                        .lavaCard()
                        .padding(.horizontal, LavaTheme.paddingLarge)
                    }
                    
                    // Delete Goal Button
                    Button(action: { showDeleteConfirmation = true }) {
                        HStack {
                            Image(systemName: "trash.fill")
                            Text("Delete Goal")
                        }
                    }
                    .buttonStyle(LavaButtonStyle(isSecondary: true))
                    .padding(.horizontal, LavaTheme.paddingLarge)
                    
                    Spacer(minLength: 20)
                }
                .padding(.bottom, LavaTheme.paddingLarge)
            }
        }
        .alert("Delete Goal", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                dataManager.deleteGoal(goalId: goal.id)
                onDismiss()
            }
        } message: {
            Text("Are you sure you want to delete this goal? This action cannot be undone.")
        }
    }
}

#Preview {
    GoalsView()
}

