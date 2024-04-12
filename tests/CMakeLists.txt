include_directories(${qlibc_SOURCE_DIR}/include/qlibc)
SET(test_list
  test_qstring
  test_qhashtbl
  test_qhasharr
  test_qhasharr_darkdh
  test_qtreetbl
  test_qlist
  test_qvector
  test_qqueue
  test_qstack
  test_qhash
)

SET(test_file_list
  test_qhash_data_1.bin
  test_qhash_data_2.bin
  test_qhash_data_3.bin
  test_qhash_data_4.bin
)

# build test
foreach(element IN LISTS test_list)
  message(STATUS "set build test: ${element}")
  add_executable(${element} ${element}.c)
  target_link_libraries(${element} qlibc qlibcext)
endforeach()

# copy test file
foreach(element IN LISTS test_file_list)
  add_custom_target(cpoy_${element} ALL
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
      ${CMAKE_CURRENT_SOURCE_DIR}/${element}
      ${CMAKE_CURRENT_BINARY_DIR}/${element}
    COMMENT "Copying ${element} to binary dir"
    VERBATIM
  )
endforeach()

# run test
foreach(element IN LISTS test_list)
  message(STATUS "set run test: ${element}")
  ADD_TEST(NAME ${element} COMMAND ${qlibc_SOURCE_DIR}/tests/launcher.sh ${element})
endforeach()
