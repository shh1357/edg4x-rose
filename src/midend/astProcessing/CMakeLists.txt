########### install files ###############

set(files_to_install
  AstPDFGeneration.h AstNodeVisitMapping.h AstAttributeMechanism.h
  AstTextAttributesHandling.h AstDOTGeneration.h AstProcessing.h
  AstSimpleProcessing.h AstTraverseToRoot.h AstNodePtrs.h
  AstSuccessorsSelectors.h AstReverseProcessing.h
  AstReverseSimpleProcessing.h Ast.h AstRestructure.h AstClearVisitFlags.h
  AstTraversal.h AstCombinedProcessing.h AstCombinedProcessingImpl.h
  AstCombinedSimpleProcessing.h StackFrameVector.h AstDOTGenerationImpl.C
  graphProcessing.h graphProcessingSgIncGraph.h graphTemplate.h
  SgGraphTemplate.h)

if (NOT WIN32)
  #tps commented out AstSharedMemoryParallelProcessing.h for Windows
  list(APPEND files_to_install AstSharedMemoryParallelProcessing.h)
endif()

install(FILES ${files_to_install} DESTINATION include)
