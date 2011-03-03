/* -*- coding: utf-8; Mode: C; tab-width: 4; c-basic-offset: 4; indent-tabs-mode: nil -*-
 * ex: set softtabstop=4 tabstop=4 shiftwidth=4 expandtab fileencoding=utf-8:
 *
 * BSD LICENSE
 * 
 * Copyright (c) 2011, Michael Truog <mjtruog at gmail dot com>
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in
 *       the documentation and/or other materials provided with the
 *       distribution.
 *     * All advertising materials mentioning features or use of this
 *       software must display the following acknowledgment:
 *         This product includes software developed by Michael Truog
 *     * The name of the author may not be used to endorse or promote
 *       products derived from this software without specific prior
 *       written permission
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
 * CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
 * DAMAGE.
 */

#ifndef CLOUDI_H
#define CLOUDI_H

#include <stdint.h>

#if defined __cplusplus
extern "C" {
#endif

#define CLOUDI_MAX_BUFFERSIZE 4194304 /* 4MB */

typedef struct {

    int fd;
    uint32_t buffer_size;
    void * lookup;
    void * buffer_send;
    void * buffer_recv;
    char * prefix;
    uint32_t timeout_async;
    uint32_t timeout_sync;
    char * response;
    uint32_t response_size;
    char * trans_id;   /* always 16 characters (128 bits) length */
    uint32_t trans_id_count;

} cloudi_instance_t;

typedef void (*cloudi_callback_t)(cloudi_instance_t * p,
                                  int const command,
                                  char const * const name,
                                  void const * const request,
                                  uint32_t const request_size,
                                  uint32_t timeout,
                                  char const * const trans_id,
                                  char const * const pid,
                                  uint32_t const pid_size);


#define cloudi_get_response(p)          (p->response)
#define cloudi_get_response_size(p)     (p->response_size)
#define cloudi_get_trans_id(p)          (p->trans_id)

int cloudi_initialize(cloudi_instance_t * p,
                      int index,
                      char const * const protocol,
                      uint32_t buffer_size);

void cloudi_destroy(cloudi_instance_t * p);

int cloudi_subscribe(cloudi_instance_t * p,
                     char const * const name,
                     cloudi_callback_t f);

int cloudi_unsubscribe(cloudi_instance_t * p,
                       char const * const name);

int cloudi_send_async(cloudi_instance_t * p,
                      char const * const name,
                      void const * const request,
                      uint32_t const request_size);

int cloudi_send_async_(cloudi_instance_t * p,
                       char const * const name,
                       void const * const request,
                       uint32_t const request_size,
                       uint32_t timeout);

int cloudi_send_sync(cloudi_instance_t * p,
                     char const * const name,
                     void const * const request,
                     uint32_t const request_size);

int cloudi_send_sync_(cloudi_instance_t * p,
                      char const * const name,
                      void const * const request,
                      uint32_t const request_size,
                      uint32_t timeout);

int cloudi_mcast_async(cloudi_instance_t * p,
                       char const * const name,
                       void const * const request,
                       uint32_t const request_size);

int cloudi_mcast_async_(cloudi_instance_t * p,
                        char const * const name,
                        void const * const request,
                        uint32_t const request_size,
                        uint32_t timeout);

int cloudi_forward(cloudi_instance_t * p,
                   int const command,
                   char const * const name,
                   void const * const request,
                   uint32_t const request_size,
                   uint32_t timeout,
                   char const * const trans_id,
                   char const * const pid,
                   uint32_t const pid_size);

int cloudi_forward_async(cloudi_instance_t * p,
                         char const * const name,
                         void const * const request,
                         uint32_t const request_size,
                         uint32_t timeout,
                         char const * const trans_id,
                         char const * const pid,
                         uint32_t const pid_size);

int cloudi_forward_sync(cloudi_instance_t * p,
                        char const * const name,
                        void const * const request,
                        uint32_t const request_size,
                        uint32_t timeout,
                        char const * const trans_id,
                        char const * const pid,
                        uint32_t const pid_size);

int cloudi_return(cloudi_instance_t * p,
                  int const command,
                  char const * const name,
                  void const * const response,
                  uint32_t const response_size,
                  uint32_t timeout,
                  char const * const trans_id,
                  char const * const pid,
                  uint32_t const pid_size);

int cloudi_return_async(cloudi_instance_t * p,
                        char const * const name,
                        void const * const response,
                        uint32_t const response_size,
                        uint32_t timeout,
                        char const * const trans_id,
                        char const * const pid,
                        uint32_t const pid_size);

int cloudi_return_sync(cloudi_instance_t * p,
                       char const * const name,
                       void const * const response,
                       uint32_t const response_size,
                       uint32_t timeout,
                       char const * const trans_id,
                       char const * const pid,
                       uint32_t const pid_size);

int cloudi_recv_async(cloudi_instance_t * p,
                      uint32_t timeout,
                      char const * const trans_id);

int cloudi_poll(cloudi_instance_t * p,
                int timeout);

enum {

    cloudi_success = 0,
    cloudi_timeout,
    cloudi_error_function_parameter,
    cloudi_error_read_EAGAIN,
    cloudi_error_read_EBADF,
    cloudi_error_read_EFAULT,
    cloudi_error_read_EINTR,
    cloudi_error_read_EINVAL,
    cloudi_error_read_EIO,
    cloudi_error_read_EISDIR,
    cloudi_error_read_unknown,
    cloudi_error_write_EAGAIN,
    cloudi_error_write_EBADF,
    cloudi_error_write_EFAULT,
    cloudi_error_write_EFBIG,
    cloudi_error_write_EINTR,
    cloudi_error_write_EINVAL,
    cloudi_error_write_EIO,
    cloudi_error_write_ENOSPC,
    cloudi_error_write_EPIPE,
    cloudi_error_write_null,
    cloudi_error_write_overflow,
    cloudi_error_write_unknown,
    cloudi_error_ei_encode,
    cloudi_error_ei_decode,
    cloudi_error_poll_EBADF,
    cloudi_error_poll_EFAULT,
    cloudi_error_poll_EINTR,
    cloudi_error_poll_EINVAL,
    cloudi_error_poll_ENOMEM,
    cloudi_error_poll_ERR,
    cloudi_error_poll_HUP,
    cloudi_error_poll_NVAL,
    cloudi_error_poll_unknown

};

#if defined __cplusplus
}
#endif

#endif /* CLOUDI_H */

