//
//  NXVComponents.swift
//  NexVaultPro
//
//  Reusable building blocks: risk dial, status pill, asset card, stat tile.
//

import SwiftUI

// MARK: - Risk dial

struct NXVRiskDial: View {
    let score: Int
    var size: CGFloat = 54

    private var band: NXVRiskBand { NXVRiskBand(score: score) }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.secondary.opacity(0.15), lineWidth: 6)
            Circle()
                .trim(from: 0, to: CGFloat(score) / 100)
                .stroke(band.tint, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .rotationEffect(.degrees(-90))
            VStack(spacing: 0) {
                Text("\(score)")
                    .font(.system(size: size * 0.32, weight: .bold, design: .rounded))
                Text("risk")
                    .font(.system(size: size * 0.16))
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: size, height: size)
        .accessibilityElement()
        .accessibilityLabel("Risk score \(score) out of 100, \(band.rawValue)")
    }
}

// MARK: - Status pill

struct NXVStatusPill: View {
    let status: NXVStatus

    var body: some View {
        Label(status.rawValue, systemImage: status.systemIcon)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(status.tint.opacity(0.15))
            .foregroundColor(status.tint)
            .clipShape(Capsule())
    }
}

// MARK: - Category badge

struct NXVCategoryBadge: View {
    let category: NXVCategory

    var body: some View {
        Image(systemName: category.systemIcon)
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.white)
            .frame(width: 40, height: 40)
            .background(category.tint.nxvGradient)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

// MARK: - Asset card

struct NXVAssetCard: View {
    let asset: NXVAssetModel
    let status: NXVStatus
    let risk: Int

    var body: some View {
        HStack(spacing: 12) {
            NXVCategoryBadge(category: asset.category)
            VStack(alignment: .leading, spacing: 4) {
                Text(asset.name)
                    .font(.headline)
                    .lineLimit(1)
                HStack(spacing: 6) {
                    NXVStatusPill(status: status)
                    if let value = asset.value {
                        Text(NXVFormat.currency(value))
                            .font(.caption.weight(.medium))
                            .foregroundColor(.secondary)
                    }
                }
            }
            Spacer()
            NXVRiskDial(score: risk, size: 48)
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

// MARK: - Stat tile

struct NXVStatTile: View {
    let title: String
    let value: String
    var systemImage: String
    var tint: Color = .accentColor

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundColor(tint)
            Text(value)
                .font(.title2.weight(.bold))
                .minimumScaleFactor(0.6)
                .lineLimit(1)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

// MARK: - Section header

struct NXVSectionHeader: View {
    let title: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        HStack {
            Text(title).font(.title3.weight(.bold))
            Spacer()
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(.subheadline)
            }
        }
    }
}

// MARK: - Empty state

struct NXVEmptyState: View {
    let systemImage: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 44))
                .foregroundColor(.secondary)
            Text(title).font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .padding(.horizontal, 24)
    }
}
