// Generated from Sgf.g4 by ANTLR 4.8
import Antlr4

/**
 * This interface defines a complete listener for a parse tree produced by
 * {@link SgfParser}.
 */
public protocol SgfListener: ParseTreeListener {
	/**
	 * Enter a parse tree produced by {@link SgfParser#collection}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterCollection(_ ctx: SgfParser.CollectionContext)
	/**
	 * Exit a parse tree produced by {@link SgfParser#collection}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitCollection(_ ctx: SgfParser.CollectionContext)
	/**
	 * Enter a parse tree produced by {@link SgfParser#gameTree}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterGameTree(_ ctx: SgfParser.GameTreeContext)
	/**
	 * Exit a parse tree produced by {@link SgfParser#gameTree}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitGameTree(_ ctx: SgfParser.GameTreeContext)
	/**
	 * Enter a parse tree produced by {@link SgfParser#sequence}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterSequence(_ ctx: SgfParser.SequenceContext)
	/**
	 * Exit a parse tree produced by {@link SgfParser#sequence}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitSequence(_ ctx: SgfParser.SequenceContext)
	/**
	 * Enter a parse tree produced by {@link SgfParser#node}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterNode(_ ctx: SgfParser.NodeContext)
	/**
	 * Exit a parse tree produced by {@link SgfParser#node}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitNode(_ ctx: SgfParser.NodeContext)
	/**
	 * Enter a parse tree produced by {@link SgfParser#property}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterProperty(_ ctx: SgfParser.PropertyContext)
	/**
	 * Exit a parse tree produced by {@link SgfParser#property}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitProperty(_ ctx: SgfParser.PropertyContext)
	/**
	 * Enter a parse tree produced by {@link SgfParser#move}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterMove(_ ctx: SgfParser.MoveContext)
	/**
	 * Exit a parse tree produced by {@link SgfParser#move}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitMove(_ ctx: SgfParser.MoveContext)
	/**
	 * Enter a parse tree produced by {@link SgfParser#setup}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterSetup(_ ctx: SgfParser.SetupContext)
	/**
	 * Exit a parse tree produced by {@link SgfParser#setup}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitSetup(_ ctx: SgfParser.SetupContext)
	/**
	 * Enter a parse tree produced by {@link SgfParser#nodeAnnotation}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterNodeAnnotation(_ ctx: SgfParser.NodeAnnotationContext)
	/**
	 * Exit a parse tree produced by {@link SgfParser#nodeAnnotation}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitNodeAnnotation(_ ctx: SgfParser.NodeAnnotationContext)
	/**
	 * Enter a parse tree produced by {@link SgfParser#moveAnnotation}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterMoveAnnotation(_ ctx: SgfParser.MoveAnnotationContext)
	/**
	 * Exit a parse tree produced by {@link SgfParser#moveAnnotation}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitMoveAnnotation(_ ctx: SgfParser.MoveAnnotationContext)
	/**
	 * Enter a parse tree produced by {@link SgfParser#markup}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterMarkup(_ ctx: SgfParser.MarkupContext)
	/**
	 * Exit a parse tree produced by {@link SgfParser#markup}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitMarkup(_ ctx: SgfParser.MarkupContext)
	/**
	 * Enter a parse tree produced by {@link SgfParser#root}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterRoot(_ ctx: SgfParser.RootContext)
	/**
	 * Exit a parse tree produced by {@link SgfParser#root}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitRoot(_ ctx: SgfParser.RootContext)
	/**
	 * Enter a parse tree produced by {@link SgfParser#gameInfo}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterGameInfo(_ ctx: SgfParser.GameInfoContext)
	/**
	 * Exit a parse tree produced by {@link SgfParser#gameInfo}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitGameInfo(_ ctx: SgfParser.GameInfoContext)
	/**
	 * Enter a parse tree produced by {@link SgfParser#timing}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterTiming(_ ctx: SgfParser.TimingContext)
	/**
	 * Exit a parse tree produced by {@link SgfParser#timing}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitTiming(_ ctx: SgfParser.TimingContext)
	/**
	 * Enter a parse tree produced by {@link SgfParser#misc}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterMisc(_ ctx: SgfParser.MiscContext)
	/**
	 * Exit a parse tree produced by {@link SgfParser#misc}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitMisc(_ ctx: SgfParser.MiscContext)
	/**
	 * Enter a parse tree produced by {@link SgfParser#loa}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterLoa(_ ctx: SgfParser.LoaContext)
	/**
	 * Exit a parse tree produced by {@link SgfParser#loa}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitLoa(_ ctx: SgfParser.LoaContext)
	/**
	 * Enter a parse tree produced by {@link SgfParser#go}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterGo(_ ctx: SgfParser.GoContext)
	/**
	 * Exit a parse tree produced by {@link SgfParser#go}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitGo(_ ctx: SgfParser.GoContext)
	/**
	 * Enter a parse tree produced by {@link SgfParser#privateProp}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func enterPrivateProp(_ ctx: SgfParser.PrivatePropContext)
	/**
	 * Exit a parse tree produced by {@link SgfParser#privateProp}.
	 - Parameters:
	   - ctx: the parse tree
	 */
	func exitPrivateProp(_ ctx: SgfParser.PrivatePropContext)
}
