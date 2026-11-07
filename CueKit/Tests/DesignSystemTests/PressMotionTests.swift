import Testing

@testable import DesignSystem

@Suite("Press motion")
struct PressMotionTests {
    @Test("At rest the button sits on its full edge")
    func resting() {
        let motion = PressMotion(depth: 6, isPressed: false, reduceMotion: false)
        #expect(motion.offset == 0)
        #expect(motion.edgeHeight == 6)
    }

    @Test("Pressed, the button sinks onto its edge")
    func pressed() {
        let motion = PressMotion(depth: 6, isPressed: true, reduceMotion: false)
        #expect(motion.offset == 6)
        #expect(motion.edgeHeight == 0)
    }

    @Test("With Reduce Motion the button does not move: only the edge disappears")
    func pressedWithReducedMotion() {
        let motion = PressMotion(depth: 6, isPressed: true, reduceMotion: true)
        #expect(motion.offset == 0)
        #expect(motion.edgeHeight == 0)
        #expect(motion.animation == nil)
    }

    @Test("Without Reduce Motion the press animates")
    func animatesNormally() {
        #expect(PressMotion(depth: 6, isPressed: true, reduceMotion: false).animation != nil)
    }
}
