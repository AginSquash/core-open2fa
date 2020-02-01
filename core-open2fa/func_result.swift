//
// Created by Vlad Vrublevsky on 01.02.2020.
// Copyright (c) 2020 Vlad Vrublevsky. All rights reserved.
//

import Foundation

enum FUNC_RESULT
{
    case SUCCEFULL

    //ERROR TYPE
    case PASS_INCORRECT
    case ALREADY_EXIST
    case FILE_NOT_EXIST
    case FILE_UNVIABLE
    case KEY2FA_NOT_EXIST
    case KEY2FA_INCORRECT
    case NO_CODES
    case ERROR_ON_CATCH
    case CANNOT_SAVE_FILE
    case CANNOT_CREATE_DIRECTORY
}