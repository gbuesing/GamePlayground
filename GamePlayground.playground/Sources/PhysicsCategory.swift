public struct PhysicsCategory {
  public static let None      : UInt32 = 0
  public static let All       : UInt32 = UInt32.max
  public static let Monster   : UInt32 = 0b1       // 1
  public static let Projectile: UInt32 = 0b10      // 2
}
