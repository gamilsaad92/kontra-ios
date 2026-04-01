import SwiftUI

  // MARK: - Color hex initializer

  extension Color {
      init(hex: String) {
          let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
          var int: UInt64 = 0
          Scanner(string: hex).scanHexInt64(&int)
          let r = Double((int >> 16) & 0xFF) / 255
          let g = Double((int >> 8)  & 0xFF) / 255
          let b = Double(int          & 0xFF) / 255
          self.init(red: r, green: g, blue: b)
      }
  }

  // MARK: - Kontra brand colors
  // Defined via ShapeStyle where Self == Color so they work with
  // .foregroundStyle(.kontraAccent), .background(.kontraBackground), etc.

  extension ShapeStyle where Self == Color {
      static var kontraPrimary:    Color { Color(hex: "#0F172A") } // Slate 900
      static var kontraAccent:     Color { Color(hex: "#3B82F6") } // Blue 500
      static var kontraGreen:      Color { Color(hex: "#22C55E") } // Green 500
      static var kontraYellow:     Color { Color(hex: "#EAB308") } // Yellow 500
      static var kontraRed:        Color { Color(hex: "#EF4444") } // Red 500
      static var kontraGray:       Color { Color(hex: "#6B7280") } // Gray 500
      static var kontraSurface:    Color { Color(hex: "#1E293B") } // Slate 800
      static var kontraBorder:     Color { Color(hex: "#334155") } // Slate 700
      static var kontraBackground: Color { Color(hex: "#0F172A") } // Slate 900
  }

  // MARK: - Status badge view

  struct StatusBadgeView: View {
      let badge: StatusBadge

      var body: some View {
          Text(badge.label)
              .font(.caption2)
              .fontWeight(.semibold)
              .padding(.horizontal, 8)
              .padding(.vertical, 3)
              .background(badgeColor.opacity(0.15))
              .foregroundStyle(badgeColor)
              .clipShape(Capsule())
      }

      private var badgeColor: Color {
          switch badge.color {
          case "green":  return Color(hex: "#22C55E")
          case "yellow": return Color(hex: "#EAB308")
          case "red":    return Color(hex: "#EF4444")
          default:       return Color(hex: "#6B7280")
          }
      }
  }

  // MARK: - Stat card

  struct StatCard: View {
      let title: String
      let value: String
      let subtitle: String?
      var accentColor: Color = Color(hex: "#3B82F6")

      var body: some View {
          VStack(alignment: .leading, spacing: 4) {
              Text(title)
                  .font(.caption)
                  .foregroundStyle(.secondary)
              Text(value)
                  .font(.title2)
                  .fontWeight(.bold)
                  .foregroundStyle(accentColor)
              if let sub = subtitle {
                  Text(sub)
                      .font(.caption2)
                      .foregroundStyle(.secondary)
              }
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding()
          .background(Color(.secondarySystemGroupedBackground))
          .clipShape(RoundedRectangle(cornerRadius: 12))
      }
  }

  // MARK: - Kontra row modifier

  struct KontraRowModifier: ViewModifier {
      func body(content: Content) -> some View {
          content
              .listRowBackground(Color(.secondarySystemGroupedBackground))
              .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
      }
  }

  extension View {
      func kontraRow() -> some View { modifier(KontraRowModifier()) }
  }
  